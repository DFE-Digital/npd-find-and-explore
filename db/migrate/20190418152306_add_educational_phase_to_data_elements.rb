# frozen_string_literal: true

class AddEducationalPhaseToDataElements < ActiveRecord::Migration[5.2]
  def change
    add_column :data_elements, :educational_phase, :string, array: true
  end
end
