# frozen_string_literal: true

module DataTable
  class Tab < ApplicationRecord
    include ProcessRows

    belongs_to :data_table_upload, class_name: 'DataTable::Upload', inverse_of: :data_table_tabs
    has_many :data_table_rows,
             class_name: 'DataTable::Row', inverse_of: :data_table_tab,
             foreign_key: :data_table_tab_id, dependent: :destroy

    attr_reader :sheet, :labels

    def initialize(args)
      table = args.delete(:workbook)
      super({ headers: {}, process_warnings: [], process_errors: [] }.merge(args))

      @labels = nil
      find_name(table.sheets)
      find_sheet(table)
    end

  private

    def tab_label
      'Tab'
    end

    def regex
      /tab/i
    end

    def headers_regex
      /(NPDAlias|NPD Alias)/i
    end

    def first_row_regex
      /census/
    end

    def find_name(tab_names)
      self.tab_name = tab_names.select { |s| /#{regex}/.match? s }.first
      process_warnings.push("Can't find tab #{tab_label} in the uploaded file") if tab_name.blank?
    end

    def find_sheet(table)
      @sheet = table.sheet_for(tab_name)
    end
  end
end
