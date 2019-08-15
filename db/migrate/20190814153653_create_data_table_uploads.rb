# frozen_string_literal: true

class CreateDataTableUploads < ActiveRecord::Migration[5.2]
  def up
    rename_table :dfe_data_tables, :data_table_uploads

    add_column :data_table_uploads, :upload_errors, :json
    add_column :data_table_uploads, :upload_warnings, :json
    add_column :data_table_uploads, :successful, :boolean, default: nil
  end

  def down
    rename_table :data_table_uploads, :dfe_data_tables

    remove_column :dfe_data_tables, :upload_errors
    remove_column :dfe_data_tables, :upload_warnings
    remove_column :dfe_data_tables, :successful
  end
end
