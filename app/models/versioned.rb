# frozen_string_literal: true

# Base class for versioned models
class Versioned < ApplicationRecord
  self.abstract_class = true

  has_paper_trail
end
