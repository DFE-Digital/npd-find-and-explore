# frozen_string_literal: true

class AddDisabledAtToAdminUser < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_users, :deactivated_at, :datetime, default: nil
  end
end
