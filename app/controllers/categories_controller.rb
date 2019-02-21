# frozen_string_literal: true

# Read resources for the Category tree
class CategoriesController < ApplicationController
  include BreadcrumbBuilder

  def index
    # TODO: shift includes into default scope?
    @categories = Category.includes(:translations).roots
  end

  def show
    @category = Category.includes(:translations).find(params.require(:id))

    breadcrumbs_for(category_leaf: @category)
  end
end
