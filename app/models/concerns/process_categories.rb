# frozen_string_literal: true

require 'active_support/concern'

module ProcessCategories
  extend ActiveSupport::Concern

  included do
    def preprocess
      save
      upload_errors = []
      upload_warnings = []
      TABLES.each do |tab_name|
        next unless workbook.sheets.include?(tab_name)

        tab = InfArch::Tab.create(inf_arch_upload: self, workbook: workbook, tab_name: tab_name)
        upload_errors.concat(tab.process_errors)
      end
      update(upload_errors: upload_errors.flatten, upload_warnings: upload_warnings.flatten)
    end

    def process
      PgSearch.disable_multisearch do
        upload(inf_arch_tabs.map(&:tree).flatten)
      end
      PgSearch::Multisearch.rebuild(Category)
      PgSearch::Multisearch.rebuild(Concept)
    end

  private

    TABLES = ['CIN-CLA', 'Demographics', 'Attainment', 'Absence-Exclusion', 'Pupil Ref Nos - KS\'s'].freeze

    def upload(categories, parent = nil)
      categories.each do |hash|
        category = find_or_create_category(hash, parent)

        category.concepts << concepts(category, hash.dig('concepts'))

        next if hash.dig('subcat').blank?

        upload(hash.dig('subcat'), category)
      end
    end

    def concepts(category, concepts)
      return [] if category.nil? || concepts.blank?

      concepts.map do |concept_hash|
        concept = Concept.find_or_create_by!(
          name: concept_hash.dig('name'),
          category: category
        )
        concept.update(description: concept_hash.dig('description'))
        update_data_elements(concept, concept_hash.dig('npd_aliases'))
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
      name = hash.dig('name')
      category = parent ? parent.children.find_by(name: name) : Category.find_by(name: name, ancestry: nil)
      if category.nil?
        category = Category.create!(name: name)
        category.parent = parent
      end
      category.description = hash.dig('description')
      category.save!
      category
    end
  end
end
