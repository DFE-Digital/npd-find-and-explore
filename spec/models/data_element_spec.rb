# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataElement, type: :model do
  before do
    create_list(:concept, 2, :with_data_elements)
  end

  it 'will compose the title from table name and attribute name' do
    data_element = DataElement.first

    expect(data_element.title).to eq([data_element.datasets.first.tab_name, data_element.unique_alias].join('.'))
  end

  it 'will print its own breadcrumb' do
    data_element = DataElement.first
    expect(data_element.breadcrumbs)
      .to eq([data_element.concept, data_element.concept.category])
  end

  it 'will recognise orphaned data elements - no orphaned data element' do
    expect(DataElement.orphaned.count).to eq(0)
  end

  it 'will recognise orphaned data elements - one orphaned data element' do
    ActiveRecord::Base.connection.execute("UPDATE data_elements SET concept_id = NULL WHERE id = '#{DataElement.first.id}'")
    expect(DataElement.orphaned.count).to eq(1)
  end

  it 'will move orphaned data elements under "no concept" when the concept is destroyed' do
    data_element = DataElement.first
    concept = data_element.concept

    expect(data_element.concept).to eq(concept)

    concept.destroy!
    expect(data_element.reload.concept.name).to eq('No Concept')
  end

  it 'will move orphaned data elements under "no concept" when the concept is removed' do
    data_element = DataElement.first
    concept = data_element.concept

    expect(data_element.concept).to eq(concept)

    data_element.concept = nil
    data_element.save!
    expect(data_element.reload.concept.name).to eq('No Concept')
  end
end
