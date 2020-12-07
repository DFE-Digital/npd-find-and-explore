# frozen_string_literal: true

# A Data Element (Data Item) represents a row of data in the database
class DataElement < ApplicationRecord
  include PgSearch::Model
  include Indexing::DataElement

  belongs_to :concept, inverse_of: :data_elements
  has_and_belongs_to_many :datasets,
                          -> { order(name: :asc) },
                          inverse_of: :data_elements

  default_scope -> { order(npd_alias: :asc) }
  scope :orphaned, -> { where(concept_id: nil).order(npd_alias: :asc) }
  scope :misplaced, -> { includes(:concept).where(concept_id: nil).or(DataElement.includes(:concept).where(concepts: { name: 'No Concept' })).order(npd_alias: :asc) }

  before_validation :assign_concept

  def dataset
    datasets.first&.tab_name
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
      concept.description = 'This Concept is used to house data items that are waiting to be categorised'
    end
    self.concept_id = no_concept.id
  end
end
