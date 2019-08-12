# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DfEDataTables::DataElementsLoader', type: :model do
  let(:table_path) { 'spec/fixtures/files/reduced_table.xlsx' }

  it 'Will perform under a given time' do
    expect do
      loader = DfEDataTables::DataElementsLoader.new(table_path)
      loader.preprocess
      loader.process
    end.to perform_under(1400).ms.sample(10)
  end

  it 'Will upload the data elements' do
    loader = DfEDataTables::DataElementsLoader.new(table_path)
    loader.preprocess
    expect { loader.process }
      .to change(DataElement, :count).by(274)
  end
end
