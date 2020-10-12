# frozen_string_literal: true

class ChangeNPDAliasToUniqueAlias < ActiveRecord::Migration[5.2]
  def change
    rename_column :data_elements, :npd_alias, :unique_alias
    rename_column :data_table_rows, :npd_alias, :unique_alias
  end
end
