# frozen_string_literal: true

# We need pgcrypto to have UUIDs as primary keys
class EnablePgcryptoExtension < ActiveRecord::Migration[5.2]
  def change
    enable_extension 'pgcrypto'
  end
end
