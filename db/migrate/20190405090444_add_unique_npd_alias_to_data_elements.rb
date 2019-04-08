# frozen_string_literal: true

class AddUniqueNpdAliasToDataElements < ActiveRecord::Migration[5.2]
  def up
    add_column :data_elements, :npd_alias, :string
    execute <<~'SQL'
      UPDATE data_elements SET npd_alias = regexp_replace(regexp_replace(additional_attributes->'npd_alias'->>0, '^ +', ''), ' +$', '')
    SQL
    change_column_null :data_elements, :npd_alias, false, ''
    add_index :data_elements, :npd_alias, unique: true
  end

  def down
    remove_column :data_elements, :npd_alias
  end
end
