# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Concept, type: :model do
  before do
    create_list(:category, 1, :with_concepts_and_data_elements)
  end

  it 'will move orphaned concepts under "no category"' do
    concept = Concept.first
    category = concept.category

    expect(concept.category).to eq(category)

    category.destroy!
    expect(concept.reload.category.name).to eq('No Category')
  end

  it 'will refuse to cancel a "no concept" with child data elements' do
    data_element = DataElement.first
    concept = data_element.concept

    concept.category.update(name: 'No Category')
    concept.update(name: 'No Concept')
    expect { concept.destroy! }.to raise_error
  end
end
