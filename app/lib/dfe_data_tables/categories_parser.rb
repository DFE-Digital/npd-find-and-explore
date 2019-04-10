# frozen_string_literal: true

module DfEDataTables
  # Parses a categories Excel sheet.
  #
  # Expects a file with a headers row that must start with 'Standard Extract' or
  # 'Category (L0)' and a fixed field structure as follows:
  #
  # * Category (L0)
  # * Category (L0) Description
  # * Category (L1)
  # * Category (L1) Description
  # * Sub-category (L2)
  # * Category (L2) Description
  # * Sub-category (L3)
  # * Category (L3) Description
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
        level_0_cat = category(row[0], row[1])
        level_1_cat = category(row[2], row[3])
        level_2_cat = category(row[4], row[5])
        level_3_cat = category(row[6], row[7])

        obj.push(level_0_cat) if level_0_cat.present?
        tree_level0 = obj&.last

        tree_level0&.dig(:subcat)&.push(level_1_cat) if level_1_cat.present?
        tree_level1 = tree_level0&.dig(:subcat)&.last

        tree_level1&.dig(:subcat)&.push(level_2_cat) if level_2_cat.present?
        tree_level2 = tree_level1&.dig(:subcat)&.last

        tree_level2&.dig(:subcat)&.push(level_3_cat) if level_3_cat.present?
        tree_level3 = tree_level2&.dig(:subcat)&.last

        concept_hash = concept(row)
        next if concept_hash.blank?

        unless tree_level3.nil?
          tree_level3[:concepts].push(concept_hash)
          next
        end

        unless tree_level2.nil?
          tree_level2[:concepts].push(concept_hash)
          next
        end

        unless tree_level1.nil?
          tree_level1[:concepts].push(concept_hash)
          next
        end

        tree_level0[:concepts].push(concept_hash)
      end
    end

  private

    def first_row
      @first_row ||= (1..sheet.last_row).each do |idx|
        row = sheet.row(idx)
        return idx + 2 if /(L0|Standard Extract)/ =~ row[0]
      end
    end

    def category(name, desc)
      return nil if name.blank?

      { name: name, description: desc, subcat: [], concepts: [] }
    end

    def concept(row)
      return nil if row[8].blank?

      { name: row[8], description: row[9], npd_aliases: npd_aliases(row) }
    end

    def npd_aliases(row)
      return [] if row[10].blank?

      row[10, row.length]
    end
  end
end
