# frozen_string_literal: true

# Modify the Data Elements model to cover for the
class AlterDataElements < ActiveRecord::Migration[5.2]
  def change
    remove_column :data_elements, :source_db_name,               :string,  required: true
    add_column    :data_elements, :source_old_attribute_name,    :string,  array: true
    add_column    :data_elements, :academic_year_collected_from, :integer
    add_column    :data_elements, :academic_year_collected_to,   :integer, default: nil
    add_column    :data_elements, :collection_terms,             :string,  array: true
    add_column    :data_elements, :values,                       :text

    reversible do |dir|
      dir.up do
        DataElement.create_translation_table! description: :text
      end

      dir.down do
        DataElement.drop_translation_table!
      end
    end
  end
end
