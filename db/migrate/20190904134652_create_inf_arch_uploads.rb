# frozen_string_literal: true

class CreateInfArchUploads < ActiveRecord::Migration[5.2]
  def change
    create_table :inf_arch_uploads, id: :uuid do |t|
      t.string     :file_name
      t.belongs_to :admin_user, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
