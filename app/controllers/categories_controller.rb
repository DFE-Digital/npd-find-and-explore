# frozen_string_literal: true

# Read resources for the Category tree
class CategoriesController < ApplicationController
  include BreadcrumbBuilder

  def index
    @categories = Category.includes(:translations).roots
    @title = t('site_title')
  end

  def show
    @category = Category.includes(:translations, concepts: %i[data_elements])
                        .find(params.require(:id))

    @title = @category.name
    breadcrumbs_for(category_leaf: @category)
  end
end
