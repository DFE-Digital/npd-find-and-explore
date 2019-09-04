# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataElement, type: :model do
  before do
    create_list(:concept, 2, :with_data_elements)
  end

  it 'will recognise orphaned data elements - no orphaned data element' do
    expect(DataElement.orphaned.count).to eq(0)
  end

  it 'will recognise orphaned data elements - one orphaned data element' do
    ActiveRecord::Base.connection.execute("UPDATE data_elements SET concept_id = NULL WHERE id = '#{DataElement.first.id}'")
    expect(DataElement.orphaned.count).to eq(1)
  end

  it 'will move orphaned data elements under "no concept"' do
    data_element = DataElement.first
    concept = data_element.concept

    expect(data_element.concept).to eq(concept)

    concept.destroy!
    expect(data_element.reload.concept.name).to eq('No Concept')
  end
end
