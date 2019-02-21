# frozen_string_literal: true

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
