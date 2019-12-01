# frozen_string_literal: true

class SearchController < ApplicationController
  include BreadcrumbBuilder

  def index
    @results = filtered_search.page(page).per(per_page)
    build_filters
    @title = t('search_title')
    @title_size = 'xl'
    breadcrumbs_for(search: true)

    render action: :index
  end

private

  def search
    PgSearch.multisearch(search_params[:search])
            .where(searchable_type: 'Concept')
            .includes(searchable: %i[data_elements category])
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
    @filters ||= params.permit(filter: { category_id: [], tab_name: [], years: [] })&.dig(:filter) || {}
  end

  def filter_results(results)
    results = filter_categories(results, filters.dig(:category_id))
    results = filter_years(results, filters.dig(:years))
    filter_tab_names(results, filters.dig(:tab_name))
  end

  def build_filters
    @categories, data_elements, active_data_elements = build_categories_and_data_elements
    @years, @tabs = build_years_tabs(data_elements, active_data_elements)
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

  def build_categories_and_data_elements
    categories = []
    data_elements = []
    active_data_elements = []
    active_search = filtered_search.map(&:searchable).map(&:id).uniq.sort
    sorted_search.map(&:searchable).each do |searchable|
      is_active = active_search.include?(searchable.id)
      categories.push(category: searchable.category, active: is_active)
      data_elements.push(searchable.data_elements)
      active_data_elements.push(searchable.data_elements) if is_active
    end
    [categories.uniq { |c| c[:category] }.sort { |a, b| a[:category].name <=> b[:category].name },
     data_elements.flatten.uniq, active_data_elements.flatten.uniq]
  end

  def build_years_tabs(data_elements, active_data_elements)
    years = []
    tabs = []
    active_years = (active_data_elements.map(&:academic_year_collected_from) +
             active_data_elements.map(&:academic_year_collected_to)).compact.uniq
    active_tabs = active_data_elements.map(&:datasets).map(&:to_a).flatten.map(&:tab_name).compact.uniq
    data_elements.each do |de|
      years.push(year: de.academic_year_collected_from, active: active_years.include?(de.academic_year_collected_from)) if de.academic_year_collected_from
      years.push(year: de.academic_year_collected_to, active: active_years.include?(de.academic_year_collected_to)) if de.academic_year_collected_to
      de.datasets.map(&:tab_name).each do |tab|
        tabs.push(tab: tab, active: active_tabs.include?(tab))
      end
    end
    [years.flatten.uniq { |y| y[:year] }.sort { |a, b| a[:year] <=> b[:year] },
     tabs.flatten.uniq { |t| t[:tab] }.sort { |a, b| a[:tab] <=> b[:tab] }]
  end
end
