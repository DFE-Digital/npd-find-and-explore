# frozen_string_literal: true

class AddDatasetIdToDataTableTabs < ActiveRecord::Migration[5.2]
  def up
    add_reference :data_table_tabs, :dataset, type: :uuid, index: true, foreign_key: true
    remove_column :data_table_tabs, :type
  end

  def down
    remove_reference :data_table_tabs, :dataset
    add_column :data_table_tabs, :type, :string, default: 'DataTable::Tab'
  end
end
