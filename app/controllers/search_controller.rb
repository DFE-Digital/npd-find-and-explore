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

  def filters
    @filters ||= params.permit(filter: { category_id: [], tab_name: [], years: [], is_cla: [] })&.dig(:filter) || {}
  end

  def filter_results(results)
    results = filter_categories(results, filters.dig(:category_id))
    results = filter_years(results, filters.dig(:years))
    results = filter_tab_names(results, filters.dig(:tab_name))
    filter_is_cla(results, filters.dig(:is_cla))
  end

  def build_filters
    @categories, data_elements = build_categories_and_data_elements
    @years, @tabs, @is_cla = build_years_tabs_and_is_cla(data_elements)
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
    filtered_search.map(&:searchable).each do |searchable|
      categories.push(searchable.category)
      data_elements.push(searchable.data_elements)
    end
    extra_categories = Category.where(id: filters[:category_id]).to_a
    [(categories + extra_categories).uniq.sort { |a, b| a.name <=> b.name }, data_elements.flatten.uniq]
  end

  def build_years_tabs_and_is_cla(data_elements)
    years = []
    tabs = []
    is_cla = []
    data_elements.each do |de|
      years.push(de.academic_year_collected_from, de.academic_year_collected_to)
      tabs.push(de.tab_name)
      is_cla.push(de.is_cla)
    end
    [(years + (filters[:years] || []).map(&:to_i)).flatten.uniq.compact.sort,
     (tabs + (filters[:tab_names] || [])).flatten.uniq.compact.sort,
     is_cla.flatten.uniq.compact]
  end
end
