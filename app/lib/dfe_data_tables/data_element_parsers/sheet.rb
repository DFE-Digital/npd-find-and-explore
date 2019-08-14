# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    # Parent class to all specific DataElement sheet parsers.
    # Holds most of the logic, delegates the specific regex definitions to the
    # children classes.
    class Sheet
      YEARS_REGEX = /_\d{2}-\d{2}(_to)?_\d{2}-\d{2}(_[A-Z]{3})?/.freeze

      attr_reader :sheet_name, :sheet, :labels, :headers, :errors

      def initialize(table)
        @labels = nil
        @headers = {}
        @errors = []
        find_name(table.sheets)
        find_sheet(table)
      end

      def check_headers
        (1..sheet.last_row).map do |idx|
          extract_header_row(idx)
        end
        @headers.delete_if { |_k, v| v.blank? }
        check_headers_for_errors
      end

      def map
        return [] if @headers.blank?

        headers_idx = [@headers.keys, sheet.last_row + 1].flatten
        headers = nil
        table_name = nil

        rows = @headers.keys.each_with_index.map do |key, idx|
          headers = @headers[key][:headers]
          table_name = @headers[key][:table]

          ((key + 1)...headers_idx[idx + 1]).map do |row_idx|
            row = sheet.row(row_idx)

            next if row[0].nil? || headers_regex =~ row[0] || headers.nil? || table_name.nil?

            element = Row.new(table_name, headers, row).process
            next if element.nil?

            block_given? ? yield(element) : element
          end
        end
        rows.flatten.compact
      end

    private

      def regex
        /census/
      end

      def headers_regex
        /(NPDAlias|NPD Alias)/i
      end

      def first_row_regex
        /census/
      end

      def find_name(sheet_names)
        @sheet_name = sheet_names.select { |s| /#{regex}/.match? s }.first
      end

      def find_sheet(table)
        @sheet = table.sheet_for(sheet_name)
      end

      def extract_header_row(idx)
        row = sheet.row(idx)
        if headers_regex.match?(row[0])
          @labels = Headers.new(row)
          @headers[idx] = { table: sheet_name, headers: @labels }
          return
        end

        return unless first_row_regex.match?(row[0])

        @headers[idx] = @headers.delete(idx - 1) || { headers: @labels }
        @headers[idx][:table] = row[0].gsub(/table/i, '').strip.gsub(/[^\w]/, '_').gsub(/_+$/, '')
      end

      def check_headers_for_errors
        @errors << "Can't find a column with header 'NPD Alias' or 'NPDAlias' for tab '#{sheet_name}'" if @headers.empty?
      end
    end
  end
end
