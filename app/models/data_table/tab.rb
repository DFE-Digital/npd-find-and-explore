# frozen_string_literal: true

module DataTable
  class Tab < ApplicationRecord
    include ProcessRows

    belongs_to :data_table_upload, class_name: 'DataTable::Upload', inverse_of: :data_table_tabs
    belongs_to :dataset, optional: true
    has_many :data_table_rows,
             class_name: 'DataTable::Row', inverse_of: :data_table_tab,
             foreign_key: :data_table_tab_id, dependent: :destroy

    default_scope -> { order(created_at: :asc) }

    scope :recognised, -> { where(recognised: true) }
    scope :unrecognised, -> { where(recognised: false) }
    scope :selected, -> { where(selected: true) }
    scope :unselected, -> { where.not(selected: true) }

    attr_reader :sheet, :labels

    def initialize(args)
      workbook = args.delete(:workbook)
      super({ headers: {}, process_warnings: [], process_errors: [] }.merge(args))

      @labels = nil
      restore_sheet(workbook: workbook)
    end

    def restore_sheet(workbook:)
      if check_tab_name(workbook)
        find_sheet(workbook)
        find_dataset
      end
    end

  private

    def first_row_regex
      /census/
    end

    def check_tab_name(workbook)
      unless tab_name
        process_warnings.push('No tab name provided')
        return false
      end
      return true if workbook.sheets.include?(tab_name)

      process_warnings.push("Can't find tab #{tab_name} in the uploaded file")
      self.tab_name = nil
    end

    def find_sheet(workbook)
      @sheet = workbook.sheet_for(tab_name)
    end

    def find_dataset
      self.dataset ||= Dataset.where('tab_regex != \'\' AND ? ~* tab_regex', tab_name).first
    end
  end
end
