# frozen_string_literal: true

class DropUnusedVersions < ActiveRecord::Migration[5.2]
  def up
    execute "DELETE FROM versions WHERE NOT item_type = 'AdminUser'"
  end

  def down
    # Irreversible migration, but no need to get all worked up...
  end
end
