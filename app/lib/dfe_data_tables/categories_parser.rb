# frozen_string_literal: true

module DfEDataTables
  # Parses a categories Excel sheet.
  #
  # Expects a file with a headers row that must start with 'Standard Extract'
  # and a fixed field structure as follows:
  #
  # * Standard Extract
  # * Category (L1)
  # * Sub-category (L2)
  # * Sub-category (L3)
  # * Concept level
  # * Concept Description
  # * NPD Alias 1
  # ... more NPD Alias columns if needed
  #
  # The Standard Extract counts as L0 category.
  # Any row above the headers row will be ignored and can be used for comments
  # and notes.
  class CategoriesParser
    attr_reader :sheet_name, :sheet

    def initialize(table, sheet_name)
      @sheet_name = sheet_name
      @sheet = table.sheet(sheet_name)
    end

    def categories
      @categories ||= sheet.each_with_index.each_with_object([]) do |row_with_index, obj|
        row, index = row_with_index
        next if (index + 1) < first_row

        obj << category(row[0]) if row[0].present?
        obj.last&.dig(:subcat)&.push(category(row[1])) if row[1].present?
        obj.last&.dig(:subcat)&.last&.dig(:subcat)&.push(category(row[2])) if row[2].present?
        obj.last&.dig(:subcat)&.last&.dig(:subcat)&.last&.dig(:subcat)&.push(category(row[3])) if row[3].present?

        next if row[4].nil?

        obj&.last&.dig(:concepts)&.push(row[4])
        obj&.last&.dig(:subcat)&.last&.dig(:concepts)&.push(row[4])
        obj&.last&.dig(:subcat)&.last&.dig(:subcat)&.last&.dig(:concepts)&.push(row[4])
        obj&.last&.dig(:subcat)&.last&.dig(:subcat)&.last&.dig(:subcat)&.last&.dig(:concepts)&.push(row[4])
      end
    end

    private

    def first_row
      @first_row ||= sheet.each_with_index do |row, id|
        return id + 2 if row[0] == 'Standard Extract'
      end
    end

    def category(name)
      { name: name, subcat: [], concepts: [] }
    end
  end
end
