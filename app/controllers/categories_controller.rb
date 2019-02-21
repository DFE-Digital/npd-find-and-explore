# frozen_string_literal: true

# Read resources for the Category tree
class CategoriesController < ApplicationController
  def index
    # TODO: shift includes into default scope?
    @categories = Category.includes(:translations).roots
  end

  def show
    # TODO: refactor and test
    @category = Category.find(params.require(:id))
  end
end
