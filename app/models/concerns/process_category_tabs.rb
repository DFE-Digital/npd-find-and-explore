# frozen_string_literal: true

require 'active_support/concern'

module ProcessCategoryTabs
  extend ActiveSupport::Concern

  included do
    def process_errors
      @process_errors ||= []
    end

  private

    HEADERS = {
      'Category L0'             => /^\w*Category \(L0\)\w*$/i,
      'Category L0 Description' => /^\w*Category \(L0\) Description\w*$/i,
      'Category L1'             => /^\w*(Sub)?-?\w?Category \(L1\)\w*$/i,
      'Category L1 Description' => /^\w*(Sub)?-?\w?Category \(L1\) Description\w*$/i,
      'Category L2'             => /^\w*(Sub)?-?\w?Category \(L2\)\w*$/i,
      'Category L2 Description' => /^\w*(Sub)?-?\w?Category \(L2\) Description\w*$/i,
      'Category L3'             => /^\w*(Sub)?-?\w?Category \(L3\)\w*$/i,
      'Category L3 Description' => /^\w*(Sub)?-?\w?Category \(L3\) Description\w*$/i,
      'Concept Level'           => /^\w*Concept Level\w*$/i,
      'Concept Description'     => /^\w*Concept Description\w*$/i,
      'NPD Alias'               => /^\w*(NPD Alias|NPDAlias)/i
    }.freeze

    def find_sheet(table)
      @sheet = table.sheet_for(tab_name)
    end

    def extract_tree
      return [] unless check_headers

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

        if l0_cat.present?
          tree_level0 = push_categories(l0_cat, categories_tree)
          tree_level1, tree_level2, tree_level3 = nil
        end

        if l1_cat.present?
          tree_level1 = push_categories(l1_cat, tree_level0&.dig(:subcat))
          tree_level2, tree_level3 = nil
        end

        if l2_cat.present?
          tree_level2 = push_categories(l2_cat, tree_level1&.dig(:subcat))
          tree_level3 = nil
        end

        tree_level3 = push_categories(l3_cat, tree_level2&.dig(:subcat)) if l3_cat.present?

        concept_hash = concept(row)
        next if concept_hash.blank?

        push_concept(tree_level3, tree_level2, tree_level1, tree_level0, concept_hash)
      end

      update(tree: categories_tree)
    end

    def check_headers
      if headers.empty?
        process_errors << "Can't find a header row for tab '#{tab_name}'. " \
                          "The first cell of a header row should read 'Category (L0)', " \
                          'are you sure the header row is present and the headers are spelt correctly?'
        return false
      end

      log_missing_headers
      process_errors.empty?
    end

    def headers
      @headers ||= begin
        row = ((1..sheet.last_row).select { |idx| HEADERS['Category L0'] =~ sheet.row(idx).dig(0) })&.first

        sheet.row(row).map { |cell| header(cell) }.reverse.drop_while(&:nil?).reverse
      end
    end

    def log_missing_headers
      HEADERS.keys.each do |header|
        next if headers.include?(header)

        process_errors << "Can't find a column with header '#{header}' for tab '#{tab_name}'"
      end
    end

    def header(cell)
      return nil if cell.is_a?(String) && cell.empty?

      HEADERS.find { |_k, v| v.match?(cell) }&.first || cell
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
