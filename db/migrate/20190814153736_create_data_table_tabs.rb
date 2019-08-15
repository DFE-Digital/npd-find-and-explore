# frozen_string_literal: true

class CreateDataTableTabs < ActiveRecord::Migration[5.2]
  def change
    create_table :data_table_tabs, id: :uuid do |t|
      t.belongs_to :data_table_upload, type: :uuid, foreign_key: true
      t.string     :tab_name
      t.json       :headers
      t.json       :errors

      t.timestamps
    end
  end
end
