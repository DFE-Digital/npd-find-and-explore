# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Category hierarchy', type: :system do
  let(:concept) { create(:concept, :with_data_elements) }
  before { concept.save! }

  it 'View the concept detail page' do
    visit concept_path(concept)

    expect(page).to have_text(concept.name)
    expect(page).to have_text(concept.description)
    expect(page).to have_title("#{concept.name} - GOV.UK")
  end

  it 'Shows the breadcrumb trail' do
    visit concept_path(concept)

    expect(page).to have_link('Home', href: categories_path)
    expect(page).to have_link(concept.category.name, href: category_path(concept.category))
  end

  it 'Shows the link to download the data table' do
    visit concept_path(concept)

    expect(page).to have_text('Can\'t find what you\'re looking for?')
    expect(page).to have_link('Click here to download the latest version of the NPD Data Tables')
  end

  it 'Doesn\'t show the data type when no data element has data type' do
    concept.data_elements.all.first.update(data_type: '')
    concept.data_elements.all.second.update(data_type: '')
    concept.data_elements.all.last.update(data_type: '')

    visit concept_path(concept)

    expect(page).not_to have_text('Data Type')
  end

  it 'Shows data type as Multiple when more than one different data type' do
    concept.data_elements.all.first.update(data_type: 'Text')
    concept.data_elements.all.second.update(data_type: 'Categorical')

    visit concept_path(concept)

    expect(page).to have_text('Data Type')
    expect(page).to have_text('Multiple')
  end

  it 'Shows data type as the common data type when same data type' do
    concept.data_elements.all.first.update(data_type: 'Dichotomous')
    concept.data_elements.all.second.update(data_type: 'Dichotomous')
    concept.data_elements.all.last.update(data_type: 'Dichotomous')

    visit concept_path(concept)

    expect(page).to have_text('Data Type')
    expect(page).to have_text('Dichotomous')
  end

  it 'Shows the sensitivity' do
    visit concept_path(concept)

    expect(page).to have_text('Sensitivity')
    expect(page).to have_text(concept.data_elements.all.map(&:sensitivity).min)
  end

  it 'Shows the identifiability' do
    visit concept_path(concept)

    expect(page).to have_text('Identifiability')
    expect(page).to have_text(concept.data_elements.all.map(&:identifiability).min)
  end

  it 'Shows the academic year this concept was collected from' do
    visit concept_path(concept)

    collected_from = concept.data_elements.all.map(&:academic_year_collected_from).min
    expect(page).to have_text('Collected from')
    expect(page).to have_text("#{collected_from} - #{(collected_from + 1).to_s[2, 2]}")
  end

  it 'Shows the elements names' do
    visit concept_path(concept)

    concept.data_elements.all.each do |element|
      expect(page).to have_text("#{element.datasets.first.tab_name}.#{element.npd_alias}")
    end
  end

  it 'Shows the elements old attribute names' do
    visit concept_path(concept)

    concept.data_elements.all.each do |element|
      expect(page).to have_text(element.source_old_attribute_name.join(', '))
    end
  end

  it 'Shows the elements collection years' do
    visit concept_path(concept)

    concept.data_elements.all.each do |element|
      year_from = element.academic_year_collected_from
      year_to = element.academic_year_collected_to
      collected = "#{year_from} - #{(year_from + 1).to_s.slice(2, 2)} to "
      collected += year_to.nil? ? 'present' : "#{year_to} - #{(year_to + 1).to_s[2, 2]}"

      expect(page).to have_text(collected)
    end
  end

  xit 'Shows the elements collection terms' do
    visit concept_path(concept)

    concept.data_elements.all.each do |element|
      term_list = { 'AUT' => 'Autumn', 'SUM' => 'Summer', 'SPR' => 'Spring' }
      terms = element.collection_terms.map { |t| term_list[t] }
      expect(page).to have_text(terms.join(', '))
    end
  end

  it 'Shows the elements values' do
    visit concept_path(concept)

    expect(page).not_to have_link('Allowed Values')
    concept.data_elements.all.each do |element|
      expect(page).to have_text(element.values)
    end
  end

  it 'Shows an overlay when the value has newlines' do
    element = concept.data_elements.all.first
    element.update(values: "Value 1\nValue 2")
    visit concept_path(concept)

    expect(page).to have_link('Allowed Values')
    expect(page).not_to have_text(element.values)

    click_on('Allowed Values')
    expect(page).to have_text(element.values)
  end

  it 'Shows an overlay when the value has more than 30 characters' do
    element = concept.data_elements.all.first
    element.update(
      values: 'Value 1, Value 2, Value 3, Value 4, Value 5, Value 6, Value 7'
    )
    visit concept_path(concept)

    expect(page).to have_link('Allowed Values')
    expect(page).not_to have_text(element.values)

    click_on('Allowed Values')
    expect(page).to have_text(element.values)
  end

  it 'Shows the elements descriptions' do
    visit concept_path(concept)

    concept.data_elements.all.each do |element|
      expect(page).to have_text(element.description)
    end
  end
end
