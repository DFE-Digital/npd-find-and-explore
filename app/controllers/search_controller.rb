# frozen_string_literal: true

class SearchController < ApplicationController
  include BreadcrumbBuilder

  def index
    @results = filtered_search.page(page).per(per_page)
    build_filters
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

  def filtered_search
    @filtered_search ||= filter_params.present? ? sorted_search.where(filter_params) : sorted_search
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

  def filter_params
    par = params.permit(filter: { category_id: [], tab_name: [], years: [], is_cla: [] })
    par.dig(:filter)
  end

  def build_filters
    @categories, data_elements = build_categories_and_data_elements
    @years, @tabs = build_years_and_tabs(data_elements)
  end

  def build_categories_and_data_elements
    categories = []
    data_elements = []
    sorted_search.map(&:searchable).each do |searchable|
      categories.push(searchable.category)
      data_elements.push(searchable.data_elements)
    end
    [categories.uniq.sort, data_elements.flatten.uniq]
  end

  def build_years_and_tabs(data_elements)
    years = []
    tabs = []
    data_elements.each do |de|
      years.push(de.academic_year_collected_from, de.academic_year_collected_to)
      tabs.push(de.tab_name)
    end
    [years.flatten.uniq.compact.sort, tabs.flatten.uniq.compact.sort]
  end
end
