# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class DataBlock
      attr_reader :header_row, :first_row, :last_row, :table_name

      def initialize(sheet, sheet_name, block)
        @sheet      = sheet
        @sheet_name = sheet_name
        @header_row = block[:header_row]
        # The first row is either explicitly specified OR the row after the header
        @first_row  = block[:first_row] || block[:header_row] + 1
        @last_row   = block[:last_row]
        # The block name is either explicitly specified OR the sheet name
        @table_name = block[:table_name] || sheet_name
      end

      def headers
        @headers ||= @sheet.row(header_row)
                           .map { |cell| header(cell) }
                           .reverse.drop_while(&:nil?).reverse
      end

      def each_row
        (first_row..last_row).each do |row_number|
          element = process_row(row_number)

          yield(element)
        end
      end

    private

      HEADERS = {
        npd_alias: /(NPDAlias|NPD Alias)/,
        field_reference: /(FieldReference|NPD Field Reference)/,
        old_alias: /(OldAlias|Old Alias)/,
        former_name: /FormerName/,
        years_populated: /Years Populated/,
        description: /Description/,
        values: /(Values|Allowed Values)/,
        source: /Source/,
        table: /Table/,
        collection_term: /Collection term/,
        tier_of_variable: /(Tier of Variable|Old Tier of Variable)/,
        available_from_udks: /Available from UKDS/,
        identification_risk: /(Identifiability|Identification Risk)/,
        sensitivity: /Sensitivity/,
        data_request_data_item_required: /Data request data item required/,
        data_request_years_required: /Data request years required/
      }.freeze

      def header(cell)
        return nil if cell.is_a?(String) && cell.empty?

        HEADERS.find { |_k, v| v.match?(cell) }&.first || cell
      end

      def process_row(row_number)
        row = @sheet.row(row_number)

        return {} if row.compact.empty?

        data_element = { table_name: table_name }

        row.each_with_index do |cell, index|
          # Don't collect (generally empty) cells outside the table
          next if headers[index].nil?

          # Cast empty strings to nil
          data_element[headers[index]] = (cell.instance_of?(String) && cell.empty? ? nil : cell)
        end

        # Post-process to add structure
        data_element[:collection_term] = data_element[:collection_term]&.split(', ')
        data_element[:npd_alias] = data_element[:npd_alias]&.split("\n")
        data_element[:years_populated] = process_years(data_element[:years_populated])

        data_element
      end

      def process_years(years_populated)
        return {} if years_populated.nil?

        years = years_populated.gsub(/(.*)\s+(only\s+|-\s+$)/, '\1 - \1')

        # Break up years into array [start, end]
        years = years.split(/ *- */)

        # Create collected_from for collection from Years Populated
        {
          from: years.dig(0)&.slice(0..3)&.to_i,
          to: years.dig(1)&.slice(0..3)&.to_i
        }
      end
    end
  end
end
