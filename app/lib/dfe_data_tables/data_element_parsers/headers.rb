# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class Headers
      attr_reader :headers

      def initialize(row)
        @headers = row.map { |cell| header(cell) }
                      .reverse.drop_while(&:nil?).reverse
      end

      def [](idx)
        headers[idx]
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
    end
  end
end
