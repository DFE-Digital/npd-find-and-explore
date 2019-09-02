# frozen_string_literal: true

class CreateDataTableRows < ActiveRecord::Migration[5.2]
  def change
    remove_column :data_table_tabs, :rows, :json, default: '{}'

    create_table :data_table_rows, id: :uuid do |t|
      t.belongs_to :data_table_upload, type: :uuid,    foreign_key: true
      t.belongs_to :concept,           type: :uuid,    foreign_key: true
      t.string     :npd_alias, required: true
      t.string     :source_table_name
      t.string     :source_attribute_name
      t.string     :source_old_attribute_name, array: true
      t.json       :additional_attributes
      t.integer    :identifiability
      t.string     :sensitivity, limit: 1
      t.integer    :academic_year_collected_from
      t.integer    :academic_year_collected_to
      t.string     :collection_terms, array: true
      t.string     :educational_phase, array: true
      t.string     :data_type
      t.text       :values
      t.text       :description_en
      t.text       :description_cy

      t.timestamps
    end

    add_index :data_table_rows, %i[data_table_upload_id npd_alias], unique: true
  end
end
