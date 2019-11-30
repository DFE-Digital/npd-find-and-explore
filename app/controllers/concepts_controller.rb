# frozen_string_literal: true

# Read resources for the Concept details pages
class ConceptsController < ApplicationController
  include BreadcrumbBuilder
  include ApplicationHelper

  def show
    @concept = Concept
               .includes(%i[data_elements category])
               .find(params.require(:id))

    @title = @concept.name
    @description = searchable_description(@concept)
    breadcrumbs_for(category_leaf: @concept.category, concept: @concept)
  end
end
