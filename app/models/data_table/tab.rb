# frozen_string_literal: true

module DataTable
  class Tab < ApplicationRecord
    include ProcessHeaders

    belongs_to :data_table_upload, class_name: 'DataTable::Upload', inverse_of: :data_table_tabs

    attr_reader :sheet, :labels

    def initialize(args)
      table = args.delete(:workbook)
      super({ headers: {}, process_warnings: [], process_errors: [] }.merge(args))

      @labels = nil
      find_name(table.sheets)
      find_sheet(table)
    end

    def map
      return [] if headers.blank?

      headers_idx = [headers.keys, sheet.last_row + 1].flatten
      headers = nil
      table_name = nil

      rows = headers.keys.each_with_index.map do |key, idx|
        headers = headers[key][:headers]
        table_name = headers[key][:table]

        ((key + 1)...headers_idx[idx + 1]).map do |row_idx|
          row = sheet.row(row_idx)

          next if row[0].nil? || headers_regex =~ row[0] || headers.nil? || table_name.nil?

          element = DfEDataTables::DataElementParsers::Row.new(table_name, headers, row).process
          next if element.nil?

          block_given? ? yield(element) : element
        end
      end
      rows.flatten.compact
    end

  private

    def tab_label
      'Tab'
    end

    def regex
      /tab/
    end

    def headers_regex
      /(NPDAlias|NPD Alias)/i
    end

    def first_row_regex
      /census/
    end

    def find_name(tab_names)
      self.tab_name = tab_names.select { |s| /#{regex}/.match? s }.first
      self.process_warnings.push("Can't find tab #{tab_label} in the uploaded file") if tab_name.blank?
    end

    def find_sheet(table)
      @sheet = table.sheet_for(tab_name)
    end
  end
end
