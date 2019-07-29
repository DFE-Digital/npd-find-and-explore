# frozen_string_literal: true

module ApplicationHelper
  ACADEMIC_TERMS = {
    aut: 'Autumn',
    spr: 'Spring',
    sum: 'Summer'
  }.freeze

  def page_title
    [@title, 'GOV.UK'].compact.join(' - ')
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
    return result.parent.name if result.parent.present?

    result.name
  end

  def sort_options
    [
      ['Recently added', 'published'],
      ['Recently updated', 'updated'],
      %w[Relevance relevance],
      ['A - Z', 'az']
    ]
  end

  def how_to_access(concept)
    identifiability = concept.data_elements.map(&:identifiability).compact.min
    identifiability > 2 ? 'how_to_access' : 'not_available'
  end
end
