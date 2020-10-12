# frozen_string_literal: true

require 'active_support/concern'

module ProcessCategories
  extend ActiveSupport::Concern

  included do
    def preprocess
      save
      upload_errors = []
      upload_warnings = []
      workbook.sheets.each do |tab_name|
        next unless TAB_REGEX =~ tab_name

        tab = InfArch::Tab.create(inf_arch_upload: self, workbook: workbook, tab_name: tab_name)
        upload_errors.concat(tab.process_errors)
      end
      if inf_arch_tabs.empty?
        upload_errors << "Can't find any suitable tab in the worksheet. A suitable tab should start with the prefix 'IA_'. " \
                         'If you proceed, all categories and concepts will be removed from the system.'
      end

      update(upload_errors: upload_errors.flatten, upload_warnings: upload_warnings.flatten)
    end

    def process
      upload(inf_arch_tabs.map(&:tree).flatten)

      update(successful: true)
    end

  private

    TAB_REGEX = /^IA_/i.freeze

    def upload(categories, parent = nil)
      categories.each do |hash|
        category = find_or_create_category(hash, parent)
        concepts(category, hash.dig('concepts'))

        subcat = hash.dig('subcat')
        upload(subcat, category) if subcat.present?
      end
    end

    def concepts(category, concepts)
      return [] if category.nil? || concepts.blank?

      concepts.map do |concept_hash|
        concept = Concept.find_or_create_by!(name: concept_hash.dig('name'), category: category) do |c|
          c.description = concept_hash.dig('description')
        end
        update_data_elements(concept, concept_hash.dig('unique_aliases'))
      end
    end

    def update_data_elements(concept, unique_aliases)
      return if concept.nil? || unique_aliases.blank?

      DataElement.where(unique_alias: unique_aliases).update_all(concept_id: concept.id)
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
