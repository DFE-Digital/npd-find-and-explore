# frozen_string_literal: true

require 'active_support/concern'

module ProcessHeaders
  extend ActiveSupport::Concern

  included do
    def check_headers
      (1..sheet.last_row).map do |idx|
        extract_header_row(idx)
      end
      headers.delete_if { |_k, v| v.blank? }
      check_headers_for_errors
      save
    end

    def extract_header_row(idx)
      row = sheet.row(idx)
      if headers_regex.match?(row[0])
        @labels = row.map { |cell| header(cell) }.reverse.drop_while(&:nil?).reverse
        headers[idx] = { table: tab_name, headers: @labels }
        return
      end

      return unless first_row_regex.match?(row[0])

      headers[idx] = headers.delete(idx - 1) || { headers: @labels }
      headers[idx][:table] = row[0].gsub(/table/i, '').strip.gsub(/[^\w]/, '_').gsub(/_+$/, '')
    end

    def check_headers_for_errors
      process_errors << "Can't find a column with header 'NPD Alias' or 'NPDAlias' for tab '#{sheet_name}'" if headers.empty?
    end

  private

    HEADERS = {
      npd_alias: /(NPDAlias|NPD Alias)/,
      field_reference: /(Field Reference|FieldReference|NPD Field Reference)/i,
      old_alias: /(OldAlias|Old Alias)/,
      former_name: /FormerName/,
      years_populated: /Years Populated/i,
      description: /Description/,
      values: /(Values|Allowed Values)/,
      source: /Source/,
      table: /Table/,
      collection_term: /Collection term/,
      tier_of_variable: /(Tier of Variable|Old Tier of Variable)/,
      available_from_udks: /Available from UKDS/,
      identification_risk: /(Identifiability|Identification Risk)/,
      sensitivity: /Sensitivity/,
      data_type: /Data Type/,
      educational_phase: /Educational Phase/,
      data_request_data_item_required: /Data request data item required/,
      data_request_years_required: /Data request years required/
    }.freeze

    def header(cell)
      return nil if cell.is_a?(String) && cell.empty?

      HEADERS.find { |_k, v| v.match?(cell) }&.first || cell
    end
  end
end
