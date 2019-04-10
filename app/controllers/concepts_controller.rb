# frozen_string_literal: true

# Read resources for the Concept details pages
class ConceptsController < ApplicationController
  include BreadcrumbBuilder

  def show
    @concept = Concept
               .includes(:translations, :data_elements, category: [:translations])
               .find(params.require(:id))

    breadcrumbs_for(category_leaf: @concept.category, concept: @concept)
  end
end
