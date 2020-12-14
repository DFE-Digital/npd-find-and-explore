# frozen_string_literal: true

class AddSupportFieldsToDataTableTabs < ActiveRecord::Migration[5.2]
  def change
    add_column :data_table_tabs, :selected, :boolean, default: false
  end
end
