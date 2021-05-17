# frozen_string_literal: true

module InfArch
  # Parses a categories Excel tab.
  #
  # Expects a file with a headers row that must start with 'Standard Extract' or
  # 'Category (L0)' and a fixed field structure as follows:
  #
  # * Category (L0)
  # * Category (L0) Description
  # * Category (L1)
  # * Category (L1) Description
  # * category (L2)
  # * Category (L2) Description
  # * category (L3)
  # * Category (L3) Description
  # * Concept level
  # * Concept Description
  # * NPD Alias 1
  # ... more NPD Alias columns if needed
  #
  # The Standard Extract counts as L0 category.
  # Any row above the headers row will be ignored and can be used for comments
  # and notes.
  class Tab < ApplicationRecord
    include ProcessCategoryTabs

    default_scope -> { order(created_at: :asc) }

    belongs_to :inf_arch_upload, class_name: 'InfArch::Upload', inverse_of: :inf_arch_tabs

    attr_reader :sheet, :categories_tree

    def initialize(args)
      table = args.delete(:workbook)
      super({ tree: {}, process_warnings: [], process_errors: [] }.merge(args))
      find_sheet(table)
      extract_tree
    end
  end
end
