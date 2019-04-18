# frozen_string_literal: true

class AddDataTypeToDataElements < ActiveRecord::Migration[5.2]
  def change
    add_column :data_elements, :data_type, :string, default: nil
  end
end
