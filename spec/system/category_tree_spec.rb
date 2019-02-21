# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Category hierarchy', type: :system do
  it 'View the categories page' do
    create_list(:category, 10, :with_subcategories)

    visit '/categories'
    expect(page).to have_text('Categories')

    top_level_categories = Category.includes(:translations).roots

    top_level_categories.each do |category|
      # We have to trim because of https://github.com/stympy/faker/pull/1545
      expect(page).to have_text(category.name.strip)
      expect(page).to have_link(category.name.strip, href: category_path(category))
      expect(page).to have_text(category.description)
    end
  end

  it 'Walks the tree to a detail page' do
    root_category = create(:category)
    child_category = create(:category, parent: root_category)
    leaf_category = create(:category, parent: child_category)
    concept = create(:concept, category: leaf_category)

    visit '/categories'
    click_link(root_category.name)
    click_link(child_category.name)
    click_link(leaf_category.name)
    click_link(concept.name)

    expect(page).to have_current_path(concept_path(concept))
    expect(page).to have_text(concept.name)
    expect(page).to have_text(concept.description)
  end

  xit 'Shows related publications' do
  end

  xit 'Has search' do
  end
end
