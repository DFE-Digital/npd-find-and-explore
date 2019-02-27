# frozen_string_literal: true

# The Data Elements model. We'll store the different attributes of the NPD tables in JSON
# for flexibility
class CreateDataElements < ActiveRecord::Migration[5.2]
  def change
    create_table :data_elements, id: :uuid do |t|
      t.string :source_db_name, required: true
      t.string :source_table_name, required: true
      t.string :source_attribute_name, required: true
      t.json :additional_attributes

      # Specific to NPD
      t.integer :identifiability
      t.string :sensitivity, limit: 1

      t.belongs_to :concept, index: true
      t.timestamps
    end
  end
end
