# frozen_string_literal: true

module DfEDataTables
  # Loads categories from an Excel document formatted as defined in the
  # CategoriesParser
  class CategoriesLoader
    def initialize(categories_path)
      categories_workbook = Roo::Spreadsheet.open(categories_path)

      @extracts = DfEDataTables::CategoriesParser.new(categories_workbook, 'Demographics - SC')

      upload(@extracts.categories)
    end

    private

    def upload(categories, parent = nil)
      categories.each do |hash|
        category = Category.find_or_create_by!(name: hash.dig(:name))
        category.update(parent: parent) if parent
        category.concepts << concepts(category, hash.dig(:concepts))

        next if hash.dig(:subcat).blank?

        upload(hash.dig(:subcat), category)
      end
    end

    def concepts(category, concepts)
      return [] if category.nil? || concepts.blank?

      concepts.map do |concept_hash|
        concept = Concept.find_or_create_by!(
          name: concept_hash.dig(:name),
          description: concept_hash.dig(:description),
          category: category
        )
        update_data_elements(concept, concept_hash.dig(:npd_aliases))
        concept
      end
    end

    def update_data_elements(concept, npd_aliases)
      return if concept.nil? || npd_aliases.blank?

      npd_aliases.each do |npd_alias|
        DataElement.where("additional_attributes->>'npd_alias' LIKE ?", "%#{npd_alias}%")
                   .each { |element| element.update!(concept: concept) }
      end
    end
  end
end
