# frozen_string_literal: true

# Datasets are mapped 1:1 to the tabs in the Data Tables Excel
class Dataset < ApplicationRecord
  include SanitizeSpace

  has_and_belongs_to_many :data_elements,
                          -> { order(unique_alias: :asc) },
                          inverse_of: :datasets, dependent: :nullify

  default_scope -> { order(name: :asc) }

  def friendly_headers_regex
    headers_regex.gsub('.?', ' ')
  end
end
