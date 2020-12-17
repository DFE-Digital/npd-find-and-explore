# frozen_string_literal: true

class AddRecognisedToDataTableTabs < ActiveRecord::Migration[5.2]
  def change
    add_column :data_table_tabs, :recognised, :boolean, default: false
  end
end
