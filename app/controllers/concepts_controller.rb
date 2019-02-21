# frozen_string_literal: true

# Read resources for the Concept details pages
class ConceptsController < ApplicationController
  def show
    # TODO: refactor and test
    @concept = Concept.includes(:translations, :category).find(params.require(:id))

    # TODO test this
    # TODO: refactor into helper
    @concept.category.ancestors.each do |category|
      breadcrumb category.name, category_path(category)
    end

    breadcrumb concept.name, concept_path(concept)

  end
end
