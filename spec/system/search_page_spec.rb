# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search pages', type: :system do
  before do
    DataElement.destroy_all
    Concept.destroy_all
    Category.destroy_all

    create(:category, :with_subcategories_concepts_and_data_elements)
    create(:category, :with_subcategories_concepts_and_data_elements)
    no_category = Category.find_or_create_by(name: 'No Category')
    Concept.find_or_create_by(name: 'No Concept', category: no_category) do |concept|
      concept.description = 'This Concept is used to house data elements that are waiting to be categorised'
    end
    DataElement.rebuild_pg_search_documents
  end

  it 'Has search' do
    visit '/categories'
    expect(page).to have_field('search')
  end

  it 'Will not find categories' do
    category = Category.where.not(name: 'No Category').first.root.children.first
    visit '/categories'
    fill_in('search', with: category.name)
    click_button('Search')

    expect(page).to have_field('search')
    expect(page).to have_title("Search results for ‘#{category.name}’ - GOV.UK")
    expect(page).to have_text("Search results for ‘#{category.name}’")
    expect(page).not_to have_text(category.parent&.name)
    expect(page).not_to have_text(category.description)
  end

  it 'Will not find concepts' do
    concept = Concept.where.not(name: 'No Concept').first
    visit '/categories'
    fill_in('search', with: concept.name)
    click_button('Search')

    expect(page).to have_field('search')
    expect(page).to have_title("Search results for ‘#{concept.name}’ - GOV.UK")
    expect(page).to have_text("Search results for ‘#{concept.name}’")
    expect(page).to have_text('No result found')
  end

  it 'Will not find no concept' do
    concept = Concept.find_by(name: 'No Concept')
    visit '/categories'
    fill_in('search', with: concept.name)
    click_button('Search')

    expect(page).to have_field('search')
    expect(page).to have_title("Search results for ‘#{concept.name}’ - GOV.UK")
    expect(page).to have_text("Search results for ‘#{concept.name}’")
    expect(page).to have_text('No result found')
  end

  it 'Will find concepts by element' do
    visit '/categories'
    fill_in('search', with: DataElement.first.unique_alias)
    click_button('Search')

    expect(page).to have_field('search')
    expect(page).to have_title("Search results for ‘#{DataElement.first.unique_alias}’ - GOV.UK")
    expect(page).to have_text("Search results for ‘#{DataElement.first.unique_alias}’")
    expect(page).to have_text(DataElement.first.concept.name)
    expect(page).to have_text(DataElement.first.unique_alias)
    expect(page).to have_text(DataElement.first.description)
  end

  context 'Filter search results' do
    before do
      datasets = Dataset.limit(6).to_a
      cla = [true, false]
      Concept.where.not(name: 'No Concept').all.each_with_index do |concept, i|
        concept.data_elements.each_with_index do |de, j|
          de.update(description: "FSM #{de.description}",
                    academic_year_collected_from: 1990 + j + (10 * i),
                    academic_year_collected_to: 1995 + j + (10 * i),
                    is_cla: cla[i % 2])
          datasets[(j * (i + 1)) % 6].data_elements << de if de.datasets.empty?
        end
      end
      DataElement.rebuild_pg_search_documents
    end

    it 'Will filter data elements by concept' do
      concept = Concept.where.not(name: 'No Concept').first
      visit '/categories'
      fill_in('search', with: 'FSM')
      click_button('Search')

      expect(page).to have_text('Found 6 exact matches')

      check("concept_id-#{concept.id}", allow_label_click: true)
      expect(page).to have_text("Found #{concept.data_elements.count} exact matches")
      expect(page).to have_text(concept.name)
    end

    it 'Will filter concepts by years' do
      visit '/categories'
      fill_in('search', with: 'FSM')
      click_button('Search')
      year = Concept.all.map(&:data_elements).flatten.map(&:academic_year_collected_from).min

      expect(page).to have_text('Found 6 exact matches')

      check("years-#{year}", allow_label_click: true)
      expect(page).to have_text('Displaying 1 result')
    end

    it 'Will filter concepts by tab names' do
      concepts = Concept.where.not(name: 'No Concept')
      concepts.first.data_elements.each { |de| de.update(datasets: [Dataset.first]) }
      concepts.last.data_elements.each { |de| de.update(datasets: [Dataset.last]) }
      DataElement.rebuild_pg_search_documents

      visit '/categories'
      fill_in('search', with: 'FSM')
      click_button('Search')
      expect(page).to have_text('Found 6 exact matches')

      tab = all('[name="filter[tab_name][]"]', visible: :any).first
      dataset = Dataset.where(tab_name: tab[:value]).select { |ds| ds.data_elements.any? }.first
      concept = dataset.data_elements.first.concept

      tab.check(allow_label_click: true)
      expect(page).to have_text('Found 3 exact matches')
      expect(page).to have_text(concept.name)
      expect(page).to have_text(dataset.data_elements.first.description)
    end
  end
end
