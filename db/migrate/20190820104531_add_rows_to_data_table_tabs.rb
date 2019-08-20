# frozen_string_literal: true

class AddRowsToDataTableTabs < ActiveRecord::Migration[5.2]
  def change
    add_column :data_table_tabs, :rows, :json, default: '{}'
  end
end
