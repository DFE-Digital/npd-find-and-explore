# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DfEDataTables::DataElementsLoader', type: :model do
  let(:table_path) { 'spec/fixtures/files/reduced_table.xlsx' }

  it 'Will perform under a given time' do
    expect { DfEDataTables::DataElementsLoader.new(table_path) }
      .to perform_under(1250).ms.sample(10)
  end

  it 'Will upload the data elements' do
    expect { DfEDataTables::DataElementsLoader.new(table_path) }
      .to change(DataElement, :count).by(274)
  end
end
