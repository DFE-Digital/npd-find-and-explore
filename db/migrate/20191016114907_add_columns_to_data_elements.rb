# frozen_string_literal: true

class AddColumnsToDataElements < ActiveRecord::Migration[5.2]
  def change
    add_column :data_elements, :tab_name, :string, default: nil
    add_column :data_elements, :standard_extract, :string, default: nil
    add_column :data_elements, :is_cla, :boolean, default: false
  end
end
