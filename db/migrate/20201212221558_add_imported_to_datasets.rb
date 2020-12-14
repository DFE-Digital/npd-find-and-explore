# frozen_string_literal: true

class AddImportedToDatasets < ActiveRecord::Migration[5.2]
  def change
    add_column :datasets, :imported, :boolean, default: false
  end
end
