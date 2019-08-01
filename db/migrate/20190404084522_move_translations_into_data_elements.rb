# frozen_string_literal: true

class MoveTranslationsIntoDataElements < ActiveRecord::Migration[5.2]
  def up
    add_column :data_elements, :description_en, :text
    add_column :data_elements, :description_cy, :text
  end

  def down
    remove_column :data_elements, :description_en, :text
    remove_column :data_elements, :description_cy, :text
  end
end
