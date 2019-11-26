# frozen_string_literal: true

# A Data Element represents a column of data in a database
class DataElement < Versioned
  include PgSearch::Model

  belongs_to :concept, inverse_of: :data_elements
  has_and_belongs_to_many :datasets, inverse_of: :data_elements

  scope :orphaned, -> { where(concept_id: nil) }

  before_validation :assign_concept

  def description
    return description_cy if I18n.locale == :cy

    description_en
  end

  def title(dataset = datasets.first)
    [dataset&.tab_name, npd_alias].join('.')
  end

  def breadcrumbs
    @breadcrumbs ||= [concept, concept&.category, concept&.category&.ancestors&.reverse].compact.flatten
  end

private

  def assign_concept
    return true if concept_id.present?

    no_category = Category.find_or_create_by(name: 'No Category')
    no_concept = Concept.find_or_create_by(name: 'No Concept', category: no_category) do |concept|
      concept.description = 'This Concept is used to house data elements that are waiting to be categorised'
    end
    self.concept_id = no_concept.id
  end
end
