# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Category hierarchy', type: :system do
  before do
    create_list(:category, 10, :with_subcategories)
  end

  it 'View the categories page' do
    visit '/categories'
    expect(page).to have_text('Categories')

    top_level_categories = Category.top_level

    top_level_categories.each do |category|
      expect(page).to have_text(category.name)
      expect(page).to have_link(category.name, href: category_path(category))
      expect(page).to have_text(category.description)
    end
  end

  # TODO: tree walk test

  xit 'Shows related publications' do
  end

  xit 'Has search' do
  end
end
