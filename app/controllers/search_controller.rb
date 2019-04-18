# frozen_string_literal: true

class SearchController < ApplicationController
  include BreadcrumbBuilder

  def index
    @results = sorted_search.page(page).per(per_page)
    breadcrumbs_for(search: true)

    render action: :index
  end

private

  def search
    PgSearch.multisearch(search_params[:search]).includes(searchable: %i[translations])
  end

  def sorted_search
    sort_param ? search.reorder(sort_param) : search
  end

  def search_params
    params.permit(:search)
  end

  def sort_param
    par = params.permit(:sort).dig(:sort)
    {
      published: { searchable_created_at: :asc },
      updated: { searchable_updated_at: :asc },
      az: { searchable_name: :asc }
    }[par.to_sym]
  end

  def page
    params.permit(:page).dig(:page) || 1
  end

  def per_page
    5
  end
end
