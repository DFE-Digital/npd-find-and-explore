# frozen_string_literal: true

require 'active_support/concern'

module ProcessRows
  extend ActiveSupport::Concern

  included do
    attr_accessor :current_table_name, :current_headers

    def preprocess
      rows = (1..sheet.last_row).map do |idx|
        element = process_row(idx)
        next if element.nil?

        block_given? ? yield(element) : element
      end
      check_headers_for_errors
      rows.flatten.compact
    end

  private

    HEADERS = {
      'npd_alias' => /(NPDAlias|NPD Alias)/,
      'field_reference' => /(Field Reference|FieldReference|NPD Field Reference)/i,
      'old_alias' => /(OldAlias|Old Alias)/,
      'former_name' => /FormerName/,
      'years_populated' => /Years Populated/i,
      'description' => /Description/,
      'values' => /(Values|Allowed Values)/,
      'source' => /Source/i,
      'table' => /Table/i,
      'standard_extract' => /(StandardExtract|Standard Extract)/i,
      'collection_term' => /(CollectionTerm|Collection Term)/i,
      'tier_of_variable' => /(Tier of Variable|Old Tier of Variable)/,
      'available_from_udks' => /Available from UKDS/,
      'identification_risk' => /(Identifiability|Identification Risk)/i,
      'sensitivity' => /Sensitivity/i,
      'data_type' => /Data Type/i,
      'educational_phase' => /Educational Phase/i,
      'data_request_data_item_required' => /Data request data item required/,
      'data_request_years_required' => /Data request years required/
    }.freeze

    def process_row(idx)
      row = sheet.row(idx)
      return if row[0].nil?
      return if extract_header_row(idx, row)

      extract_row(row)
    end

    def header(cell)
      return nil if cell.is_a?(String) && cell.empty?

      HEADERS.find { |_k, v| v.match?(cell) }&.first || cell
    end

    def check_headers_for_errors
      return if tab_name.blank?

      process_errors << "Can't find a column with header 'NPD Alias' or 'NPDAlias' for tab '#{tab_name}'" if headers.empty?
    end

    def extract_header_row(idx, row)
      return set_headers(idx, row) if headers_regex.match?(row[0])
      return set_table_name(idx, row) if first_row_regex.match?(row[0])

      false
    end

    def extract_row(row)
      return if current_headers.nil? || current_table_name.nil?

      element = DfEDataTables::DataElementParsers::Row.new(current_table_name, current_headers, tab_name, row).process
      return if element.nil?

      element
    end

    def set_headers(idx, row)
      self.current_headers = row.map { |cell| header(cell) }.reverse.drop_while(&:nil?).reverse
      headers[idx] = { table: tab_name, headers: current_headers }
      self.current_table_name = tab_name
      true
    end

    def set_table_name(idx, row)
      headers[idx] = headers.delete(idx - 1) || { headers: current_headers }
      headers[idx][:table] = row[0].gsub(/table/i, '').strip.gsub(/[^\w]/, '_').gsub(/_+$/, '')
      self.current_table_name = headers[idx][:table]
      true
    end
  end
end
