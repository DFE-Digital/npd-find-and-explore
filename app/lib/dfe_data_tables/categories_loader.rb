# frozen_string_literal: true

module DfEDataTables
  class CategoriesLoader
    def initialize(categories_path)
      categories_workbook = Roo::Spreadsheet.open(categories_path)

      @extracts = DfEDataTables::CategoriesParser.new(categories_workbook, 'Demographics - SC')

      upload(@extracts.categories)
    end

    private

    def upload(categories, parent = nil)
      categories.each do |hash|
        category = Category.find_or_create_by!(name: hash[:name])
        category.update(parent: parent) if parent
        category.concepts << concepts(category, hash[:concepts])

        next if hash[:subcat].blank?

        upload(hash[:subcat], category)
      end
    end

    def concepts(category, concept_list)
      return [] if category.nil? || concept_list.blank?

      concept_list.map do |name|
        Concept.find_or_create_by!(name: name, category: category)
      end
    end
  end
end

