# frozen_string_literal: true

class DeleteVersionsForTempTables < ActiveRecord::Migration[5.2]
  def up
    execute("DELETE FROM versions WHERE item_type = 'InfArch::Upload'")
    execute("DELETE FROM versions WHERE item_type = 'InfArch::Tab'")
    execute("DELETE FROM versions WHERE item_type = 'DataTable::Upload'")
    execute("DELETE FROM versions WHERE item_type = 'DataTable::Tab'")
    execute("DELETE FROM versions WHERE item_type = 'DataTable::Row'")
  end

  def down
    # nothing to do
  end
end
