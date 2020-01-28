# frozen_string_literal: true

class AddFkToDatabase < ActiveRecord::Migration[5.2]
  def up
    # remove orphaned translations
    execute 'DELETE FROM category_translations WHERE category_id NOT IN (SELECT id FROM categories)'
    execute 'DELETE FROM concept_translations WHERE concept_id NOT IN (SELECT id FROM concepts)'

    # set to 'no concept' orphaned data elements
    # 2020-01-28 Kept as historical documentation, removing the Globalize gem renders this inoperable
    # at this point of the development
    # PgSearch.disable_multisearch do
    #   category = Category.find_or_create_by(name: 'No Category')
    #   concept ||= Concept.find_or_create_by(name: 'No Concept', category: category) do |c|
    #     c.description = 'This Concept is used to house data elements that are waiting to be categorised'
    #   end
    #   DataElement.where.not(concept_id: Concept.pluck(:id)).update(concept: concept)
    # end

    add_foreign_key :category_translations, :categories, uuid: true, on_delete: :cascade
    add_foreign_key :concept_translations, :concepts, uuid: true, on_delete: :cascade
    add_foreign_key :concepts, :categories, uuid: true, on_delete: :nullify
    add_foreign_key :data_elements, :concepts, uuid: true, on_delete: :nullify
  end

  def down
    remove_foreign_key :category_translations, :categories
    remove_foreign_key :concept_translations, :concepts
    remove_foreign_key :concepts, :categories
    remove_foreign_key :data_elements, :concepts
  end
end
