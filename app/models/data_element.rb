# frozen_string_literal: true

# A Data Element represents a column of data in a database
class DataElement < ApplicationRecord
  include PgSearch

  belongs_to :concept, inverse_of: :data_elements

  translates :description

  multisearchable against: %i[
                    description
                    source_table_name
                    source_attribute_name
                    additional_attributes
                    identifiability
                    sensitivity
                    source_old_attribute_name
                    academic_year_collected_from
                    academic_year_collected_to
                    collection_terms
                    values
                  ]

  def title
    [source_table_name, source_attribute_name].join('.')
  end
end
