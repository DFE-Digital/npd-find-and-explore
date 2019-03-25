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

      def to_h
        {
          name: sheet_name,
          data_blocks: data_blocks
        }
      end

      def data_blocks
        @data_blocks ||= significant_rows[:header_rows]&.each_with_index&.map do |row, index|
          DfEDataTables::DataElementParsers::DataBlock.new(
            sheet,
            sheet_name,
            {
              header_row: row,
              first_row: significant_rows.dig(:first_rows, index),
              last_row: significant_rows.dig(:last_rows, index),
              table_name: significant_rows.dig(:table_names, index)
            }
          )
        end
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

      def significant_rows
        return @significant_rows unless @significant_rows.nil?

        object = { header_rows: [], first_rows: [], last_rows: [], table_names: [] }
        @significant_rows = (1..sheet.last_row).each_with_object(object) do |idx, obj|
          row = sheet.row(idx)
          obj[:header_rows] << idx if headers_regex.match? row[0]
          next if obj[:header_rows].last.nil?

          if first_row_regex.match? row[0]
            obj[:first_rows] << (idx + 1)
            obj[:table_names] << row[0].gsub(/table/i, '').strip.gsub(/[^\w]/, '_').gsub(/_+$/, '')
            obj[:header_rows] << obj[:header_rows].last if obj[:first_rows].count > obj[:header_rows].count
          end

          next if obj[:header_rows].count == obj[:last_rows].count

          obj[:last_rows] << (idx - 1) if row[0].nil? && (idx - 1) > obj[:header_rows].last
        end
        @significant_rows[:last_rows] << sheet.last_row
        @significant_rows
      end
    end
  end
end
