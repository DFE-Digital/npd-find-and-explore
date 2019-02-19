class CategoriesController < ApplicationController

  def index
    @categories = Category.top_level
  end

  def show
    # TODO: refactor and test
    @category = Category.find(params.require(:id))
  end
end
