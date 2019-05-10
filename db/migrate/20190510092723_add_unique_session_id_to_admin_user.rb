# frozen_string_literal: true

class AddUniqueSessionIdToAdminUser < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_users, :unique_session_id, :string, default: nil
  end
end
