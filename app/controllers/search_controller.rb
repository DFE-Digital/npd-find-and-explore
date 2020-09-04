# frozen_string_literal: true

class SearchController < ApplicationController
  include BreadcrumbBuilder

  def index
    @results = filtered_search.page(page).per(per_page)
    build_filters
    @title = t('search_title')
    @title_size = 'xl'
    breadcrumbs_for(custom: { name: 'Search', path: search_index_path })

    render action: :index
  end

private

  def search
    PgSearch.multisearch(search_params[:search])
            .where(searchable_type: 'DataElement')
            .includes(searchable: %i[concept])
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
    @filters ||= params.permit(filter: { concept_id: [], tab_name: [], years: [] })&.dig(:filter) || {}
  end

  def filter_results(results)
    results = filter_concepts(results, filters.dig(:concept_id))
    results = filter_years(results, filters.dig(:years))
    filter_tab_names(results, filters.dig(:tab_name))
  end

  def build_filters
    @concepts = build_concepts
    @years, @tabs = build_years_tabs
  end

  def filter_concepts(results, concept_ids)
    return results if concept_ids.blank?

    results.where(searchable_category_id: concept_ids)
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
    results.where(["(#{query.join(' AND ')})"].concat(query_params))
  end

  def filter_tab_names(results, tab_names)
    return results if tab_names.blank?

    results.where.overlap(searchable_tab_names: tab_names)
  end

  def build_concepts
    concepts = []
    active_search = filtered_search.map(&:searchable).map(&:id).uniq.sort
    sorted_search.map(&:searchable).each do |searchable|
      is_active = active_search.include?(searchable.id)
      concepts.push(concept: searchable.concept, active: is_active)
    end
    concepts.uniq { |c| c[:concept] }.sort { |a, b| a[:concept].name <=> b[:concept].name }
  end

  def build_years_tabs
    years = []
    tabs = []
    active_tabs = @filtered_search.map(&:searchable).map(&:datasets).map(&:to_a).flatten.map(&:tab_name).compact.uniq
    @sorted_search.map(&:searchable).each do |de|
      years.push(collect_years(de, @filtered_search.include?(de)))
      de.datasets.map(&:tab_name).each do |tab|
        tabs.push(tab: tab, active: active_tabs.include?(tab))
      end
    end
    [years.flatten.sort { |a, b| (a[:active] ? 0 : 1) <=> (b[:active] ? 0 : 1) }.uniq { |y| y[:year] }.sort { |a, b| a[:year] <=> b[:year] },
     tabs.flatten.sort { |a, b| (a[:active] ? 0 : 1) <=> (b[:active] ? 0 : 1) }.uniq { |t| t[:tab] }.sort { |a, b| a[:tab] <=> b[:tab] }]
  end

  def collect_years(data_element, active)
    current_year = Time.now.year
    ((data_element.academic_year_collected_from || current_year)..(data_element.academic_year_collected_to || current_year)).map do |year|
      { year: year, active: active }
    end
  end
end
