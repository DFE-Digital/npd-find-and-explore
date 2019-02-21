# frozen_string_literal: true

# Read resources for the Concept details pages
class ConceptsController < ApplicationController
  def show
    # TODO: refactor and test
    @concept = Concept.includes(:translations).find(params.require(:id))
  end
end
