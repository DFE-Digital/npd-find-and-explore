# frozen_string_literal: true

class AddColumnsToDataTableRows < ActiveRecord::Migration[5.2]
  def change
    add_column :data_table_rows, :tab_name, :string, default: nil
    add_column :data_table_rows, :standard_extract, :string, default: nil
    add_column :data_table_rows, :is_cla, :boolean, default: false
  end
end
