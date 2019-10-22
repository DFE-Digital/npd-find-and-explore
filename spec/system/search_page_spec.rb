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

  it 'Will filter concepts by category' do
    Concept.all.each_with_index { |concept, i| concept.update(name: "FSM #{i}") }
    visit '/'
    fill_in('search', with: 'FSM')
    click_button('Search')

    expect(page).to have_text('Showing all 2 results')

    check("category_id-#{Concept.first.category_id}", allow_label_click: true)
    expect(page).to have_text('Displaying 1 result')
    expect(page).to have_text(Concept.first.category.name.upcase)
    expect(page).to have_text(Concept.first.description)
  end
end
