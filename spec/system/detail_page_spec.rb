# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Category hierarchy', type: :system do
  let(:concept) { create(:concept, :with_data_elements) }

  it 'View the concept detail page' do
    visit concept_path(concept)

    expect(page).to have_text(concept.name)
    expect(page).to have_text(concept.description)
  end

  it 'Shows the breadcrumb trail' do
    visit concept_path(concept)

    expect(page).to have_link('Home', href: categories_path)
    expect(page).to have_link(concept.category.name, href: category_path(concept.category))
  end

  it 'Shows the sensitivity' do
    visit concept_path(concept)

    expect(page).to have_text('Sensitivity')
    expect(page).to have_text(concept.data_elements.map(&:sensitivity).min)
  end

  it 'Shows the elements names' do
    visit concept_path(concept)

    concept.data_elements.each do |element|
      expect(page).to have_text("#{element.source_table_name}.#{element.source_attribute_name}")
    end
  end

  it 'Shows the elements old attribute names' do
    visit concept_path(concept)

    concept.data_elements.each do |element|
      expect(page).to have_text(element.source_old_attribute_name.join(', '))
    end
  end

  it 'Shows the elements collection years' do
    visit concept_path(concept)

    concept.data_elements.each do |element|
      year_from = element.academic_year_collected_from
      year_to = element.academic_year_collected_to
      collected = "#{year_from} - #{(year_from + 1).to_s.slice(2, 2)} to "
      collected += year_to.nil? ? 'present' : "#{year_to} - #{(year_to + 1).to_s[2, 2]}"

      expect(page).to have_text(collected)
    end
  end

  it 'Shows the elements collection terms' do
    visit concept_path(concept)

    concept.data_elements.each do |element|
      term_list = { 'AUT' => 'Autumn', 'SUM' => 'Summer', 'SPR' => 'Spring' }
      terms = element.collection_terms.map { |t| term_list[t] }
      expect(page).to have_text(terms.join(', '))
    end
  end

  it 'Shows the elements values' do
    visit concept_path(concept)

    concept.data_elements.each do |element|
      expect(page).to have_text(element.values)
    end
  end

  it 'Shows the elements descriptions' do
    visit concept_path(concept)

    concept.data_elements.each do |element|
      expect(page).to have_text(element.description)
    end
  end
end
