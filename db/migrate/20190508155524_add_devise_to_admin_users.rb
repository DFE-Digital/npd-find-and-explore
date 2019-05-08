# frozen_string_literal: true

class AddDeviseToAdminUsers < ActiveRecord::Migration[5.2]
  def self.up
    change_table :admin_users do |t|
      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at
    end

    add_index :admin_users, :unlock_token, unique: true
  end

  def self.down
    remove_index  :admin_users, :unlock_token
    remove_column :admin_users, :failed_attempts
    remove_column :admin_users, :unlock_token
    remove_column :admin_users, :locked_at
  end
end
