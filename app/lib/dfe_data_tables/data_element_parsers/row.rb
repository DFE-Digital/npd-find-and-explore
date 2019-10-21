# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class Row
      attr_reader :table_name, :headers, :tab_name, :row

      def initialize(table_name, headers, tab_name, row)
        @tab_name = tab_name
        @table_name = table_name
        @headers = headers
        @row = row
      end

      def process
        return nil if table_name.nil? || row.compact.first.nil?

        data_element = { table_name: table_name, tab_name: tab_name }

        row.each_with_index do |cell, index|
          # Don't collect (generally empty) cells outside the table
          next if headers[index].nil?

          # Cast empty strings to nil
          data_element[headers[index].to_sym] = parse_cell(cell)
        end

        # Post-process to add structure
        data_element[:collection_term] = data_element[:collection_term]&.split(', ')
        data_element[:npd_alias] = data_element[:npd_alias]&.split("\n")&.map(&:strip)&.select(&:present?)
        data_element[:years_populated] = process_years(data_element[:years_populated])

        invalid?(data_element) ? nil : data_element_params(data_element)
      end

    private

      def parse_cell(cell)
        cell = cell.strip if cell.instance_of?(String)
        cell.presence
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

      def invalid?(data_element)
        data_element.empty? || data_element[:npd_alias].nil? ||
          data_element[:field_reference].nil?
      end

      def data_element_params(data_element)
        {
          npd_alias: data_element.dig(:npd_alias, 0),
          tab_name: data_element.dig(:tab_name),
          source_table_name: data_element.dig(:table_name),
          source_attribute_name: data_element.dig(:field_reference),
          source_old_attribute_name: [data_element.dig(:old_alias), data_element.dig(:former_name)].flatten.compact,
          identifiability: data_element.dig(:identification_risk),
          sensitivity: data_element.dig(:sensitivity),
          academic_year_collected_from: data_element.dig(:years_populated, :from),
          academic_year_collected_to: data_element.dig(:years_populated, :to),
          standard_extract: data_element.dig(:standard_extract),
          is_cla: /CIN.?CLA/i.match?(data_element.dig(:standard_extract)),
          collection_terms: data_element.dig(:collection_term),
          values: data_element.dig(:values),
          description_en: data_element.dig(:description),
          description_cy: '',
          data_type: data_element.dig(:data_type)&.split&.map(&:capitalize)&.join(' '),
          educational_phase: data_element.dig(:educational_phase)&.split(',')&.map(&:strip)&.map(&:upcase),
          additional_attributes: data_element
        }
      end
    end
  end
end
