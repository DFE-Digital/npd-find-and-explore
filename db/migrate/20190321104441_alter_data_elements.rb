# frozen_string_literal: true

# Modify the Data Elements model to cover for the
class AlterDataElements < ActiveRecord::Migration[5.2]
  def change
    remove_column :data_elements, :source_db_name, :string, required: true
    add_column    :data_elements, :source_old_attribute_name, :string, required: true
    add_column    :data_elements, :date_collected_from,       :string
    add_column    :data_elements, :date_collected_to,         :string, default: nil
    add_column    :data_elements, :collection_terms,          :string, array: true
    add_column    :data_elements, :values,                    :string, array: true
  end
end
