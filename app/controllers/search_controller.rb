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
    @filtered_search ||= filter_results(sorted_search)
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
    10
  end

  def filter_results(results)
    par = params.permit(filter: { category_id: [], tab_name: [], years: [], is_cla: [] })
    pars = par&.dig(:filter) || {}
    results = filter_categories(results, pars.dig(:category_id))
    results = filter_years(results, pars.dig(:years))
    results = filter_tab_names(results, pars.dig(:tab_name))
    filter_is_cla(results, pars.dig(:is_cla))
  end

  def build_filters
    @categories, data_elements = build_categories_and_data_elements
    @years, @tabs = build_years_and_tabs(data_elements)
  end

  def filter_categories(results, category_ids)
    return results if category_ids.blank?

    results.where(searchable_category_id: category_ids)
  end

  def filter_years(results, years)
    return results if years.blank?

    query = []
    query_params = []
    years.each do |year|
      query.push('(? BETWEEN searchable_year_from AND searchable_year_to OR ' \
                 '(? >= searchable_year_from AND searchable_year_to IS NULL) OR ' \
                 '(? <= searchable_year_to AND searchable_year_from IS NULL))')
      query_params.push(year, year, year)
    end
    results.where(["(#{query.join(' OR ')})"].concat(query_params))
  end

  def filter_tab_names(results, tab_names)
    return results if tab_names.blank?

    results.where.overlap(searchable_tab_names: tab_names)
  end

  def filter_is_cla(results, is_cla)
    return results if is_cla.blank?

    results.where.overlap(searchable_is_cla: is_cla.uniq)
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
