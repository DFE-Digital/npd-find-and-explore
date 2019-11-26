# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Category hierarchy', type: :system do
  before { create_list(:category, 4, :with_subcategories) }

  it 'View the categories page' do
    visit '/categories'
    expect(page).to have_text('Categories')
    expect(page).to have_title('Find and explore data in the National Pupil Database - GOV.UK')

    top_level_categories = Category.real.includes(:translations).roots

    top_level_categories.each do |category|
      expect(page).to have_text(category.name)
      expect(page).to have_link(category.name, href: category_path(category))
      expect(page).to have_text(category.description)
    end
  end

  it 'Has datasets in the categories page' do
    visit '/categories'
    expect(page).to have_text('Datasets')

    datasets = Dataset.includes(:translations).all

    datasets.each do |dataset|
      expect(page).to have_text(dataset.name)
      expect(page).to have_link(dataset.name, href: dataset_path(dataset))
      expect(page).to have_text(dataset.description)
    end
  end

  it 'View a category page' do
    top_level_category = Category.includes(:translations).roots.first
    second_level_categories = top_level_category.children

    visit '/categories'
    click_link(top_level_category.name)
    expect(page).to have_text(top_level_category.name)
    expect(page).to have_text(top_level_category.description)
    expect(page).to have_title("#{top_level_category.name} - GOV.UK")

    second_level_categories.each do |category|
      expect(page).to have_text(category.name)
      expect(page).to have_link(category.name, href: category_path(category))
      expect(page).to have_text(category.description)
    end
  end

  it 'Has search' do
    visit '/categories'
    expect(page).to have_field('search')
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
    expect(page).to have_title("#{concept.name} - GOV.UK")
  end

  it 'Shows the breadcrumb trail' do
    root_category = create(:category)
    child_category = create(:category, parent: root_category)
    leaf_category = create(:category, parent: child_category)

    visit category_path(leaf_category)

    expect(page).to have_link('Home', href: categories_path)
    expect(page).to have_link(root_category.name, href: category_path(root_category))
    expect(page).to have_link(child_category.name, href: category_path(child_category))
  end
end
