# frozen_string_literal: true

# Read resources for the Category tree
class CategoriesController < ApplicationController
  include BreadcrumbBuilder

  def index
    @categories = Category.real.roots
    @datasets = Dataset.all
    @title = t('site_title')
  end

  def show
    @category = Category.includes(concepts: %i[data_elements])
                        .find(params.require(:id))

    @title = @category.name
    @description = @category.description
    breadcrumbs_for(category_leaf: @category)
  end
end
