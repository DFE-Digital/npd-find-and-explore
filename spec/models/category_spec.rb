# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Category, type: :model do
  before do
    DataElement.destroy_all
    Concept.destroy_all
    Category.destroy_all
    create_list(:category, 2, :with_subcategories_concepts_and_data_elements)
  end

  it 'will put the newly created category first' do
    category = Category.create(name: 'New Category', description: 'Description')

    expect(category.position).to eq(1)
    expect(Category.roots.pluck(:position).sort).to eq([1, 2, 3])
  end

  it 'will rootify orphaned nodes' do
    root = Category.first.root
    children = root.children

    children.each do |child|
      expect(child.parent).to eq(root)
    end

    root.destroy!
    children.each do |child|
      expect(child.reload).to be_root
    end
  end

  it 'will refuse to cancel a "no category" with child concepts' do
    concept = Concept.first
    category = concept.category

    category.update(name: 'No Category')
    expect { category.destroy! }.to raise_error ActiveRecord::NotNullViolation
  end
end
