# frozen_string_literal: true

# Datasets are mapped 1:1 to the tabs in the Data Tables Excel
class Dataset < ApplicationRecord
  has_and_belongs_to_many :data_elements,
                          inverse_of: :datasets, dependent: :nullify

  translates :name
  translates :description

  default_scope -> { order(name: :asc) }
end
