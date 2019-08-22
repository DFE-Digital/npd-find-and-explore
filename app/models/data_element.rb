# frozen_string_literal: true

# A Data Element represents a column of data in a database
class DataElement < ApplicationRecord
  include PgSearch::Model

  belongs_to :concept, inverse_of: :data_elements

  def description
    return description_cy if I18n.locale == :cy

    description_en
  end

  def title
    [source_table_name, source_attribute_name].join('.')
  end
end
