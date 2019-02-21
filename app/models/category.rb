# frozen_string_literal: true

class Category < ApplicationRecord
  translates :name
  translates :description

  has_ancestry
end
