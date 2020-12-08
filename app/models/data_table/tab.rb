# frozen_string_literal: true

module DataTable
  class Tab < ApplicationRecord
    include ProcessRows

    belongs_to :data_table_upload, class_name: 'DataTable::Upload', inverse_of: :data_table_tabs
    belongs_to :dataset, optional: true
    has_many :data_table_rows,
             class_name: 'DataTable::Row', inverse_of: :data_table_tab,
             foreign_key: :data_table_tab_id, dependent: :destroy

    scope :recognised, -> { where('dataset_id IS NOT NULL') }
    scope :unrecognised, -> { where('dataset_id IS NULL') }
    scope :selected, -> { where(selected: true) }

    attr_reader :sheet, :labels

    def initialize(args)
      table = args.delete(:workbook)
      super({ headers: {}, process_warnings: [], process_errors: [] }.merge(args))

      @labels = nil
      if check_tab_name(table)
        find_sheet(table)
        find_dataset
      end
    end

  private

    def first_row_regex
      /census/
    end

    def check_tab_name(table)
      unless tab_name
        process_warnings.push('No tab name provided')
        return false
      end
      return true if table.sheets.include?(tab_name)

      process_warnings.push("Can't find tab #{tab_name} in the uploaded file")
      self.tab_name = nil
    end

    def find_sheet(table)
      @sheet = table.sheet_for(tab_name)
    end

    def find_dataset
      self.dataset = Dataset.where('? ~* tab_regex', tab_name).first
    end
  end
end
