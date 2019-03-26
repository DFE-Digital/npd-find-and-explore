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
      @sheet = table.sheet_for(sheet_name)
    end

    def categories
      @categories ||= (1..sheet.last_row).each_with_object([]) do |idx, obj|
        row = sheet.row(idx)
        next if (idx + 1) < first_row

        row = row.reverse.drop_while(&:nil?).reverse

        obj.push(category(row[0])) if row[0].present?
        obj.last&.dig(:subcat)&.push(category(row[1])) if row[1].present?
        obj.last&.dig(:subcat)&.last&.dig(:subcat)&.push(category(row[2])) if row[2].present?
        obj.last&.dig(:subcat)&.last&.dig(:subcat)&.last&.dig(:subcat)&.push(category(row[3])) if row[3].present?

        next if row[4].blank?

        concept_hash = concept(row)

        if row[3].present?
          obj&.last&.dig(:subcat)&.last&.dig(:subcat)&.last&.dig(:subcat)&.last&.dig(:concepts)&.push(concept_hash)
          next
        end

        if row[2].present?
          obj&.last&.dig(:subcat)&.last&.dig(:subcat)&.last&.dig(:concepts)&.push(concept_hash)
          next
        end

        if row[1].present?
          obj&.last&.dig(:subcat)&.last&.dig(:concepts)&.push(concept_hash)
          next
        end

        obj&.last&.dig(:concepts)&.push(concept_hash)
      end
    end

  private

    def first_row
      @first_row ||= (1..sheet.last_row).each do |idx|
        row = sheet.row(idx)
        return idx + 2 if row[0] == 'Standard Extract'
      end
    end

    def category(name)
      { name: name, subcat: [], concepts: [] }
    end

    def concept(row)
      { name: row[4], description: row[5], npd_aliases: npd_aliases(row) }
    end

    def npd_aliases(row)
      return [] if row[6].blank?

      row[6, row.length]
    end
  end
end
