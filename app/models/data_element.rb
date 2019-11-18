# frozen_string_literal: true

# A Data Element represents a column of data in a database
class DataElement < Versioned
  include PgSearch::Model

  belongs_to :concept, inverse_of: :data_elements
  has_and_belongs_to_many :datasets, inverse_of: :data_elements

  scope :orphaned, -> { where(concept_id: nil) }

  def description
    return description_cy if I18n.locale == :cy

    description_en
  end

  def title
    [tab_name, npd_alias].join('.')
  end

  def breadcrumbs
    @breadcrumbs ||= [concept, concept&.category, concept&.category&.ancestors&.reverse].compact.flatten
  end
end
