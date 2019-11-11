# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'Saved items panel' do
  it 'Has the saved items panel' do
    expect(page).to have_css('.npd-saved-data', text: 'My list')
  end
end

RSpec.describe 'Saved item list', type: :system do
  before do
    DataElement.destroy_all
    Concept.destroy_all
    Category.destroy_all

    create_list(:category, 2, :with_subcategories_concepts_and_data_elements)
  end

  context 'Search pages' do
    before do
      visit '/categories'
      fill_in('search', with: 'FSM')
      click_button('Search')
    end
    include_examples 'Saved items panel'
  end

  context 'Categories index' do
    before { visit '/categories' }
    include_examples 'Saved items panel'
  end

  context 'Category detail' do
    before { visit "/categories/#{Category.first.id}" }
    include_examples 'Saved items panel'
  end

  context 'Concept detail' do
    before { visit "/concepts/#{Concept.first.id}" }
    include_examples 'Saved items panel'
  end
end
