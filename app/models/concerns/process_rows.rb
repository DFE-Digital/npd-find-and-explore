# frozen_string_literal: true

require 'active_support/concern'

module ProcessRows
  extend ActiveSupport::Concern

  included do
    attr_accessor :table_name

    def check_rows
      return [] if headers.blank?

      current_headers = nil
      headers_idx = [headers.keys.map(&:to_i), sheet.last_row + 1].flatten
      table_name = nil

      tab_rows = headers.keys.each_with_index.map do |key, idx|
        current_headers = headers[key]['headers']
        table_name = headers[key]['table']

        ((key.to_i + 1)...headers_idx[idx + 1]).map do |row_idx|
          row = sheet.row(row_idx)

          next if row[0].nil? || headers_regex =~ row[0] || current_headers.nil? || table_name.nil?

          element = DfEDataTables::DataElementParsers::Row.new(table_name, current_headers, row).process
          next if element.nil?

          element
        end
      end
      update(rows: tab_rows.flatten.compact)
      rows
    end
  end
end
