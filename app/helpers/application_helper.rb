# frozen_string_literal: true

module ApplicationHelper
  ACADEMIC_TERMS = {
    aut: 'Autumn',
    spr: 'Spring',
    sum: 'Summer'
  }.freeze

  def academic_year(year)
    return 'present' if year.blank?

    "#{year} - #{(year + 1).to_s[2, 2]}"
  end

  def academic_term(term)
    ACADEMIC_TERMS[term&.downcase&.to_sym] || term
  end
end
