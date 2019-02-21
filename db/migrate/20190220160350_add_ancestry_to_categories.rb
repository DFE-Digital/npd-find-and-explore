# frozen_string_literal: true

# Introduce Ancestry gem to categories to provide a nested tree
class AddAncestryToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :ancestry, :string
    add_column :categories, :position, :integer
    add_index :categories, :ancestry
    add_index :categories, %i[ancestry position]

    remove_column :categories, :parent_id, :integer
  end
end
