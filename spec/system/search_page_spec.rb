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
    visit '/categories'
    expect(page).to have_field('search')
  end

  it 'Will find categories' do
    visit '/categories'
    fill_in('search', with: Category.first.name)
    click_button('Search')

    expect(page).to have_field('search')
    expect(page).to have_title('Search results - GOV.UK')
    expect(page).to have_text("Results for '#{Category.first.name}'")
    expect(page).to have_text(Category.first.parent&.name&.upcase)
    expect(page).to have_text(Category.first.description)
  end

  it 'Will find concepts' do
    visit '/categories'
    fill_in('search', with: Concept.first.name)
    click_button('Search')

    expect(page).to have_field('search')
    expect(page).to have_title('Search results - GOV.UK')
    expect(page).to have_text("Results for '#{Concept.first.name}'")
    expect(page).to have_text(Concept.first.category.name.upcase)
    expect(page).to have_text(Concept.first.description)
  end

  it 'Will find concepts by element' do
    visit '/categories'
    fill_in('search', with: DataElement.first.source_table_name)
    click_button('Search')

    expect(page).to have_field('search')
    expect(page).to have_title('Search results - GOV.UK')
    expect(page).to have_text("Results for '#{DataElement.first.source_table_name}'")
    expect(page).to have_text(DataElement.first.concept.category.name.upcase)
    expect(page).to have_text(DataElement.first.concept.description)
  end
end
