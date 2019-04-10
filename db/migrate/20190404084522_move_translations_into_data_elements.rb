# frozen_string_literal: true

class MoveTranslationsIntoDataElements < ActiveRecord::Migration[5.2]
  def up
    add_column :data_elements, :description_en, :text
    add_column :data_elements, :description_cy, :text

    drop_table :data_element_translations
  end

  def down
    DataElement.create_translation_table! description: :text

    remove_column :data_elements, :description_en, :text
    remove_column :data_elements, :description_cy, :text
  end
end
