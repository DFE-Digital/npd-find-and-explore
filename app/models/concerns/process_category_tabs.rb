# frozen_string_literal: true

require 'active_support/concern'

module ProcessCategoryTabs
  extend ActiveSupport::Concern

  included do
    def process_errors
      @process_errors ||= []
    end

  private

    def find_sheet(table)
      @sheet = table.sheet_for(tab_name)
    end

    def extract_tree
      return [] unless check_first_row

      categories_tree = []
      tree_level0 = nil
      tree_level1 = nil
      tree_level2 = nil
      tree_level3 = nil

      (1..sheet.last_row).each do |idx|
        row = sheet.row(idx)
        next if (idx + 1) < first_row

        row = row.reverse.drop_while(&:nil?).reverse
        l0_cat, l1_cat, l2_cat, l3_cat = extract_categories(row)

        tree_level0 = push_categories(l0_cat, categories_tree) if l0_cat.present?
        tree_level1 = push_categories(l1_cat, tree_level0&.dig(:subcat)) if l1_cat.present?
        tree_level2 = push_categories(l2_cat, tree_level1&.dig(:subcat)) if l2_cat.present?
        tree_level3 = push_categories(l3_cat, tree_level2&.dig(:subcat)) if l3_cat.present?

        concept_hash = concept(row)
        next if concept_hash.blank?

        push_concept(tree_level3, tree_level2, tree_level1, tree_level0, concept_hash)
      end

      update(tree: categories_tree)
    end

    def check_first_row
      return true if first_row.present?

      process_errors << "Can't find a column with header 'L0' or 'Standard Extract' for tab '#{tab_name}'"
      false
    end

    def first_row
      @first_row ||= ((1..sheet.last_row).select { |idx| /(L0|Standard Extract)/ =~ sheet.row(idx).dig(0) })&.first&.+ 2
    end

    def category(name, desc)
      return nil if name.blank?

      { name: name.strip.gsub(/\s+/, ' '), description: desc, subcat: [], concepts: [] }
    end

    def concept(row)
      return nil if row[8].blank?

      { name: row[8].strip.gsub(/\s+/, ' '), description: row[9], npd_aliases: npd_aliases(row) }
    end

    def npd_aliases(row)
      return [] if row[10].blank?

      row[10, row.length]
    end

    def extract_categories(row)
      [category(row[0], row[1]), category(row[2], row[3]),
       category(row[4], row[5]), category(row[6], row[7])]
    end

    def push_categories(category, branch)
      branch.push(category)
      branch&.last
    end

    def push_concept(tree_level3, tree_level2, tree_level1, tree_level0, concept_hash)
      return tree_level3[:concepts].push(concept_hash) unless tree_level3.nil?
      return tree_level2[:concepts].push(concept_hash) unless tree_level2.nil?
      return tree_level1[:concepts].push(concept_hash) unless tree_level1.nil?

      tree_level0[:concepts].push(concept_hash)
    end
  end
end
