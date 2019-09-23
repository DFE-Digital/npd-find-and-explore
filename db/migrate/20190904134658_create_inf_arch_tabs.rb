# frozen_string_literal: true

class CreateInfArchTabs < ActiveRecord::Migration[5.2]
  def change
    create_table :inf_arch_tabs, id: :uuid do |t|
      t.belongs_to :inf_arch_upload, type: :uuid, foreign_key: true
      t.string     :tab_name
      t.json       :tree
      t.json       :process_errors
      t.json       :process_warnings

      t.timestamps
    end
  end
end
