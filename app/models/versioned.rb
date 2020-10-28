# frozen_string_literal: true

# Base class for versioned models
class Versioned < ApplicationRecord
  self.abstract_class = true

  # Temporarily disable as the PO doesn't have immediate plans for this and it's
  # only clogging the database.
  # Re-enable when the PO decides to do something with it, or remove completely
  # if they decide it's not needed.

  # has_paper_trail
end
