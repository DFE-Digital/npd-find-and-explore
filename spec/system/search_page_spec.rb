# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search pages', type: :system do
  before do
    DataElement.destroy_all
    Concept.destroy_all
    Category.destroy_all

    create_list(:category, 2, :with_subcategories_concepts_and_data_elements)
    PgSearch::Multisearch.rebuild(Category)
    PgSearch::Multisearch.rebuild(Concept)
  end

  it 'Has search' do
    visit '/'
    expect(page).to have_field('search')
  end

  it 'Will not find categories' do
    category = Category.first.root.children.first
    visit '/'
    fill_in('search', with: category.name)
    click_button('Search')

    expect(page).to have_field('search')
    expect(page).to have_title('Search results - GOV.UK')
    expect(page).to have_text("Results for '#{category.name}'")
    expect(page).not_to have_text(category.parent&.name&.upcase)
    expect(page).not_to have_text(category.description)
  end

  it 'Will find concepts' do
    visit '/'
    fill_in('search', with: Concept.first.name)
    click_button('Search')

    expect(page).to have_field('search')
    expect(page).to have_title('Search results - GOV.UK')
    expect(page).to have_text("Results for '#{Concept.first.name}'")
    expect(page).to have_text(Concept.first.category.name.upcase)
    expect(page).to have_text(Concept.first.description)
  end

  it 'Will find concepts by element' do
    visit '/'
    fill_in('search', with: DataElement.first.source_attribute_name)
    click_button('Search')

    expect(page).to have_field('search')
    expect(page).to have_title('Search results - GOV.UK')
    expect(page).to have_text("Results for '#{DataElement.first.source_attribute_name}'")
    expect(page).to have_text(DataElement.first.concept.category.name.upcase)
    expect(page).to have_text(DataElement.first.concept.description)
  end

  context 'Filter search results' do
    before do
      tabs = %w[Year7 KS2 KS3 KS4 KS5 CLA]
      cla = [true, false]
      Concept.all.each_with_index do |concept, i|
        concept.data_elements.each_with_index do |de, j|
          de.update(academic_year_collected_from: 1990 + j + (10 * i),
                    academic_year_collected_to: 1995 + j + (10 * i),
                    tab_name: tabs[(j * (i + 1)) % 6],
                    is_cla: cla[i % 2])
        end
        concept.update(name: "FSM #{i}")
      end
      PgSearch::Multisearch.rebuild(Concept)
    end

    it 'Will filter concepts by category' do
      visit '/'
      fill_in('search', with: 'FSM')
      click_button('Search')

      expect(page).to have_text('Showing all 2 results')

      check("category_id-#{Concept.first.category_id}", allow_label_click: true)
      expect(page).to have_text('Displaying 1 result')
      expect(page).to have_text(Concept.first.category.name.upcase)
      expect(page).to have_text(Concept.first.description)
    end

    it 'Will filter concepts by years' do
      visit '/'
      fill_in('search', with: 'FSM')
      click_button('Search')
      year = Concept.all.map(&:data_elements).flatten.map(&:academic_year_collected_from).min

      expect(page).to have_text('Showing all 2 results')

      check("years-#{year}", allow_label_click: true)
      expect(page).to have_text('Displaying 1 result')
    end

    it 'Will filter concepts by tab names' do
      visit '/'
      fill_in('search', with: 'FSM')
      click_button('Search')
      concept = Concept.first
      tabs = concept.data_elements.map(&:tab_name) - Concept.last.data_elements.map(&:tab_name)

      expect(page).to have_text('Showing all 2 results')

      check("tab_name-#{tabs.first}", allow_label_click: true)
      expect(page).to have_text('Displaying 1 result')
      expect(page).to have_text(concept.category.name.upcase)
      expect(page).to have_text(concept.description)
    end

    it 'Will filter concepts by is_cla value' do
      visit '/'
      fill_in('search', with: 'FSM')
      click_button('Search')
      concept = Concept.first
      check_id = concept.data_elements.first.is_cla? ? 'is_cla-yes' : 'is_cla-no'

      expect(page).to have_text('Showing all 2 results')

      check(check_id, allow_label_click: true)
      expect(page).to have_text('Displaying 1 result')
      expect(page).to have_text(concept.category.name.upcase)
      expect(page).to have_text(concept.description)
    end
  end
end
