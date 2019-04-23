# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    # Parent class to all specific DataElement sheet parsers.
    # Holds most of the logic, delegates the specific regex definitions to the
    # children classes.
    class Sheet
      YEARS_REGEX = /_\d{2}-\d{2}(_to)?_\d{2}-\d{2}(_[A-Z]{3})?/.freeze

      attr_reader :sheet_name, :sheet

      def initialize(table)
        find_name(table.sheets)
        find_sheet(table)
      end

      def map
        table_name = nil
        headers = nil
        started = false

        rows = (1..sheet.last_row).map do |idx|
          row = sheet.row(idx)

          if row[0].nil?
            table_name = nil
            next
          end

          if headers_regex.match?(row[0])
            started = true
            table_name = sheet_name
            headers = Headers.new(row)
            next
          end

          if first_row_regex.match? row[0]
            table_name = row[0].gsub(/table/i, '').strip.gsub(/[^\w]/, '_').gsub(/_+$/, '')
            next
          end

          next if !started || headers.nil? || table_name.nil?

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
    end
  end
end
