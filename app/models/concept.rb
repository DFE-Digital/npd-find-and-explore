# frozen_string_literal: true

# A concept groups Data Elements that
# *mean the same thing*
#
# e.g. Free School Meals in Last 6 Years (concept) contains
#       - KS2Pupil.EVERFSM_6
#       - SchoolCensus.FSM6
class Concept < Versioned
  include SanitizeSpace
  include Indexing::Concept

  belongs_to :category, inverse_of: :concepts
  has_many :data_elements,
           dependent: :nullify, inverse_of: :concept,
           after_remove: :reassign_to_no_concept

  validates :name, uniqueness: { scope: :category }
  before_destroy :reassign_data_elements, prepend: true

  def placeholder_description
    data_elements&.max { |a, b| (a&.description&.length || 0) <=> (b&.description&.length || 0) }&.description
  end

  def data_type
    types = data_elements&.collect(&:data_type)&.compact&.uniq
    return nil if types.empty?

    types.length == 1 ? types.first : 'Multiple'
  end

  def reassign_data_elements
    return true if data_elements.count.zero?
    raise(ActiveRecord::NotNullViolation, 'Cannot delete "No Concept" with data elements') if name == 'No Concept' && data_elements.count.positive?

    no_category = Category.find_or_create_by(name: 'No Category')
    no_concept = Concept.find_or_create_by(name: 'No Concept', category: no_category) do |concept|
      concept.description = 'This Concept is used to house data elements that are waiting to be categorised'
    end
    data_elements.each do |data_element|
      data_element.update(concept: no_concept)
    end
    reload
  end

  def reassign_to_no_concept(data_element)
    raise(ActiveRecord::NotNullViolation, 'Cannot delete "No Concept" with data elements') if name == 'No Concept'

    no_category = Category.find_or_create_by(name: 'No Category')
    no_concept = Concept.find_or_create_by(name: 'No Concept', category: no_category) do |concept|
      concept.description = 'This Concept is used to house data elements that are waiting to be categorised'
    end

    data_element.update(concept: no_concept)
  end

  def self.childless
    search = arel_table
             .project('concepts.id AS id, COUNT(data_elements) AS data_elements_count')
             .join(DataElement.arel_table, Arel::Nodes::OuterJoin).on('data_elements.concept_id = concepts.id')
             .group('concepts.id')

    where("concepts.id IN (SELECT id FROM (#{search.to_sql}) AS search WHERE search.data_elements_count = 0)")
  end
end
