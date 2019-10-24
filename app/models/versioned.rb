# frozen_string_literal: true

class Versioned < ApplicationRecord
  self.abstract_class = true

  has_paper_trail
end
