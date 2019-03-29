# frozen_string_literal: true

# A concept groups Data Elements that
# *mean the same thing*
#
# e.g. Free School Meals in Last 6 Years (concept) contains
#       - KS2Pupil.EVERFSM_6
#       - SchoolCensus.FSM6
class Concept < ApplicationRecord
  include PgSearch

  belongs_to :category, inverse_of: :concepts
  has_many :data_elements, dependent: :nullify, inverse_of: :concept

  validates :name, uniqueness: { scope: :category }

  translates :name
  translates :description

  multisearchable against: %i[name description],
                  additional_attributes: ->(concept) { { result_id: concept.id, result_type: 'Concept' } }
end
