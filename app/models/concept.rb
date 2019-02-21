# A concept groups Data Elements that
# *mean the same thing*
#
# e.g. Free School Meals in Last 6 Years (concept) contains
#       - KS2Pupil.EVERFSM_6
#       - SchoolCensus.FSM6
class Concept < ApplicationRecord
  belongs_to :category

  translates :name
  translates :description
end
