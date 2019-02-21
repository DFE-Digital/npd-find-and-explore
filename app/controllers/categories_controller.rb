# frozen_string_literal: true

# Read resources for the Category tree
class CategoriesController < ApplicationController
  def index
    # TODO: shift includes into default scope?
    @categories = Category.includes(:translations).roots
  end

  def show
    @category = Category.includes(:translations).find(params.require(:id))

    # TODO: refactor and test
    @category.ancestors.each do |category|
      breadcrumb category.name, category_path(category)
    end
    breadcrumb @category.name, category_path(@category)
  end
end
