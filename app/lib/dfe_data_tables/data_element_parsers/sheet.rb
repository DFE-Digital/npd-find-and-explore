# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    # Parent class to all specific DataElement sheet parsers.
    # Holds most of the logic, delegates the specific regex definitions to the
    # children classes.
    class Sheet
      YEARS_REGEX = /_\d{2}-\d{2}(_to)?_\d{2}-\d{2}(_[A-Z]{3})?/.freeze

      attr_reader :sheet_name, :sheet, :headers, :errors

      def initialize(table)
        @headers = {}
        @errors = []
        find_name(table.sheets)
        find_sheet(table)
      end

      def check_headers
        table_name = nil
        headers = nil
        header_row_no = nil

        (1..sheet.last_row).map do |idx|
          row = sheet.row(idx)

          if row[0].nil?
            header_row_no = nil
            table_name = nil
            next
          end

          if headers_regex.match?(row[0])
            header_row_no = idx
            table_name = sheet_name
            headers = Headers.new(row)
            @headers[header_row_no] = { table: table_name, headers: headers }
            next
          end

          next unless first_row_regex.match?(row[0])

          @headers[header_row_no] = nil if header_row_no
          header_row_no = idx
          @headers[header_row_no] = {
            table: row[0].gsub(/table/i, '').strip.gsub(/[^\w]/, '_').gsub(/_+$/, ''),
            headers: headers
          }
        end
        @headers.delete_if { |_k, v| v.blank? }
        check_headers_for_errors
      end

      def map
        return [] if @headers.blank?

        headers_idx = @headers.keys
        headers = nil
        table_name = nil

        rows = (headers_idx.first..sheet.last_row).map do |idx|
          if headers_idx.include?(idx)
            headers = @headers[idx][:headers]
            table_name = @headers[idx][:table]
            next
          end

          row = sheet.row(idx)

          if row[0].nil? || headers.nil? || table_name.nil?
            headers = nil
            table_name = nil
          end

          element = Row.new(table_name, headers, row).process
          next if element.nil?

          block_given? ? yield(element) : element
        end
        rows.compact
      end

    private

      def regex
        /census/
      end

      def headers_regex
        /(NPDAlias|NPD Alias)/
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

      def check_headers_for_errors
        @errors << "Can't find a column with header 'NPD Alias' or 'NPDAlias' for tab '#{sheet_name}'" if @headers.empty?
      end
    end
  end
end
