# frozen_string_literal: true

class CreateDataTableUploads < ActiveRecord::Migration[5.2]
  def change
    create_table :data_table_uploads, id: :uuid do |t|
      t.string     :file_name
      t.belongs_to :admin_user, type: :uuid, foreign_key: true
      t.json       :errors
      t.json       :warnings

      t.timestamps
    end
  end
end
