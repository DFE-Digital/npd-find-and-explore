# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class Row
      attr_reader :table_name, :headers, :row

      def initialize(table_name, headers, row)
        @table_name = table_name
        @headers = headers
        @row = row
      end

      def process
        return {} if table_name.nil? || row.compact.first.nil?

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

        invalid?(data_element) ? {} : data_element
      end

    private

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

      def invalid?(data_element)
        data_element.empty? || data_element[:npd_alias].nil? ||
          data_element[:field_reference].nil?
      end
    end
  end
end
