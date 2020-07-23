# frozen_string_literal: true

module ApplicationHelper
  ACADEMIC_TERMS = {
    aut: 'Autumn',
    spr: 'Spring',
    sum: 'Summer'
  }.freeze

  def page_title(title)
    [title, 'GOV.UK'].compact.join(' - ')
  end

  def academic_year(year)
    return 'present' if year.blank?

    "#{year} - #{(year + 1).to_s[2, 2]}"
  end

  def academic_term(term)
    ACADEMIC_TERMS[term&.downcase&.to_sym] || term
  end

  def google_analytics_key
    Rails.application.credentials.dig(Rails.env.to_sym, :google_analytics_tracking_id)
  end

  def google_manager_key
    Rails.application.credentials.dig(Rails.env.to_sym, :google_manager_id)
  end

  def search_category_tag(result)
    return result.category.name if result.respond_to?(:category)
    return result.parent.name if result&.parent&.present?

    result&.name
  end

  def searchable_description(result)
    return result.description if result.is_a?(Category)

    result.description || result.placeholder_description
  end

  def sort_options
    [
      %w[Relevance relevance],
      ['A - Z', 'az']
    ]
  end

  def root_page?
    params[:controller] == 'search' || (params[:controller] == 'categories' && params[:action] == 'index')
  end

  def saved_items_page?
    params[:controller] == 'saved_items'
  end

  def shared_header?
    params[:controller] != 'high_voltage/pages'
  end

  def cookie_choice_page?
    params[:controller] == 'high_voltage/pages' && params[:id] == 'cookie-preferences'
  end

  def usage_cookies_allowed?
    cookies_policy = begin
                       JSON.parse(cookies['cookies_policy'])
                     rescue JSON::ParserError
                       { 'essential' => true, 'usage' => false }
                     end

    cookies_policy['usage']
  end
end
