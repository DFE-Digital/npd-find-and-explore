# frozen_string_literal: true

# Datasets are mapped 1:1 to the tabs in the Data Tables Excel
class Dataset < ApplicationRecord
  include SanitizeSpace

  before_save :loosen_regexps

  has_and_belongs_to_many :data_elements,
                          -> { order(unique_alias: :asc) },
                          inverse_of: :datasets, dependent: :nullify
  has_many :data_table_tabs,
           class_name: 'DataTable::Tab'

  default_scope -> { order(name: :asc) }

  def friendly_headers_regex
    headers_regex&.gsub('.?', ' ')
  end

private

  def loosen_regexps
    self.headers_regex = (headers_regex || '').gsub('.?', ' ').gsub(/[^a-zA-Z0-9]/, '.?')
  end
end
