# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataElement, type: :model do
  before do
    create_list(:concept, 1, :with_data_elements)
  end

  it 'will move orphaned data elements under "no concept"' do
    data_element = DataElement.first
    concept = data_element.concept

    expect(data_element.concept).to eq(concept)

    concept.destroy!
    expect(data_element.reload.concept.name).to eq('No Concept')
  end
end
