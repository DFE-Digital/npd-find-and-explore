# frozen_string_literal: true

class Search < PgSearch::Document
  belongs_to :result, polymorphic: true
end
