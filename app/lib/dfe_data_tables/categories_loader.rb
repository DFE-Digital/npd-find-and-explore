# frozen_string_literal: true

module DfEDataTables
  # Loads categories from an Excel document formatted as defined in the
  # CategoriesParser
  class CategoriesLoader
    TABLES = ['Demographics', 'Attainment', 'Absence-Exclusion', 'Pupil Ref Nos - KS\'s'].freeze

    def initialize(categories_path)
      categories_workbook = Roo::Spreadsheet.open(categories_path)

      PgSearch.disable_multisearch do
        TABLES.each do |table|
          worksheet = DfEDataTables::CategoriesParser.new(categories_workbook, table)
          upload(worksheet.categories)
        end
      end
      PgSearch::Multisearch.rebuild(Category)
      PgSearch::Multisearch.rebuild(Concept)
    end

  private

    def upload(categories, parent = nil)
      categories.each do |hash|
        category = find_or_create_category(hash, parent)

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
        DataElement.where(npd_alias: npd_alias)
                   .each { |element| element.update!(concept: concept) }
      end
    end

    def find_or_create_category(hash, parent = nil)
      name = hash.dig(:name)
      category = parent ? parent.children.find_by(name: name) : Category.find_by(name: name, ancestry: nil)
      if category.nil?
        category = Category.create!(name: name)
        category.parent = parent
      end
      category.description = hash.dig(:description)
      category.save!
      category
    end
  end
end
