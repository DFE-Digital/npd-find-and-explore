# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  context 'page_title' do
    it 'Will append the GOV.UK to the page title' do
      expect(page_title('Title')).to eq('Title - GOV.UK')
    end
  end

  context 'academic_year' do
    it 'Will turn the starting year into an academic year' do
      expect(academic_year(2012)).to eq('2012 - 13')
    end
  end

  context 'academic_term' do
    it 'Will return the academic term if valid' do
      expect(academic_term('aut')).to eq('Autumn')
    end

    it 'Will return the argument if invalid academic term' do
      expect(academic_term('Invalid')).to eq('Invalid')
    end
  end

  context 'search_category_tag' do
    let(:root_category) { create :category, :with_subcategories_and_concepts }
    let(:concept) { root_category.descendants.last.concepts.first }

    it 'Will return the category name if concept' do
      expect(search_category_tag(concept)).to eq(concept.category.name)
    end

    it 'Will return the parent name if non-root category' do
      expect(search_category_tag(concept.category)).to eq(concept.category.parent.name)
    end

    it 'Will return the name if root category' do
      expect(search_category_tag(root_category)).to eq(root_category.name)
    end
  end

  context 'searchable_description' do
    let(:category) { create :category, :with_subcategories_concepts_and_data_elements }
    let(:concept) { category.descendants.last.concepts.first }

    it 'Will return the description if result a category' do
      expect(searchable_description(category)).to eq(category.description)
    end

    it 'Will return the description if result a concept with a description' do
      expect(searchable_description(concept)).to eq(concept.description)
    end

    it 'Will return the placeholder description if result a concept without a description' do
      concept.update!(description: nil)
      expect(searchable_description(concept)).to eq('')
    end
  end
end
