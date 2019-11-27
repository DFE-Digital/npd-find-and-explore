# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Concept, type: :model do
  before do
    DataElement.destroy_all
    Concept.destroy_all
    Category.destroy_all
    create_list(:category, 1, :with_concepts_and_data_elements)
  end

  it 'will default the placeholder description to the longest amongst its data elements when description is missing' do
    concept = Concept.first
    concept.update(description: nil)

    expected_placeholder = concept.data_elements&.max { |a, b| (a&.description&.length || 0) <=> (b&.description&.length || 0) }&.description
    expect(concept.placeholder_description).to eq(expected_placeholder)
  end

  it 'will create a No Concept with its own description when deleting all other concepts' do
    Concept.first.destroy

    expect(Concept.count).to eq(1)
    expect(Concept.first.name).to eq('No Concept')
    expect(Concept.first.description)
      .to eq('This Concept is used to house data elements that are waiting to be categorised')
  end

  it 'will move orphaned concepts under "no category"' do
    concept = Concept.first
    category = concept.category

    expect(concept.category).to eq(category)

    category.destroy!
    expect(concept.reload.category.name).to eq('No Category')
  end

  it 'will move orphaned data elements under "no concept" when the element is removed' do
    data_element = DataElement.first
    concept = data_element.concept

    expect(data_element.concept).to eq(concept)

    concept.update(data_elements: [])
    expect(data_element.reload.concept.name).to eq('No Concept')
  end

  it 'will refuse to cancel a "no concept" with child data elements' do
    data_element = DataElement.first
    concept = data_element.concept

    concept.category.update(name: 'No Category')
    concept.update(name: 'No Concept')
    expect { concept.destroy! }.to raise_error ActiveRecord::NotNullViolation
  end

  it 'will refuse to remove an element from "no concept"' do
    data_element = DataElement.first
    concept = data_element.concept

    concept.category.update(name: 'No Category')
    concept.update(name: 'No Concept')

    expect { concept.update(data_elements: []) }.to raise_error ActiveRecord::NotNullViolation
  end
end
