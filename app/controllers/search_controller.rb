# frozen_string_literal: true

class SearchController < ApplicationController
  include BreadcrumbBuilder

  def index
    @results = sorted_search.page(page).per(per_page)
    searchables = sorted_search.map(&:searchable)
    @categories = searchables.map(&:category).uniq.sort
    data_elements = searchables.map(&:data_elements).flatten.uniq
    @years = (data_elements.map(&:academic_year_collected_from) + data_elements.map(&:academic_year_collected_to)).flatten.uniq.compact.sort
    @tabs = data_elements.map(&:tab_name).flatten.uniq.compact.sort
    @title = t('search_title')
    breadcrumbs_for(search: true)

    render action: :index
  end

private

  def search
    PgSearch.multisearch(search_params[:search])
            .where(searchable_type: 'Concept')
            .includes(searchable: %i[translations])
  end

  def sorted_search
    @sorted_search ||= sort_param ? search.reorder(sort_param) : search
  end

  def search_params
    params.permit(:search)
  end

  def sort_param
    par = params.permit(:sort).dig(:sort)&.to_sym
    {
      published: { searchable_created_at: :desc },
      updated: { searchable_updated_at: :desc },
      az: { searchable_name: :asc }
    }[par]
  end

  def page
    params.permit(:page).dig(:page) || 1
  end

  def per_page
    5
  end
end
