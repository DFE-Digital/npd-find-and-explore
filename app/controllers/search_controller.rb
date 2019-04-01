# frozen_string_literal: true

class SearchController < ApplicationController
  def index
    @results = search.page(page).per(per_page)
    render action: :index
  end

private

  def search
    PgSearch.multisearch(search_params[:search]).includes(searchable: %i[translations])
  end

  def search_params
    params.permit(:search)
  end

  def page
    params.permit(:page).dig(:page) || 1
  end

  def per_page
    5
  end
end
