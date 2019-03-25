# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DfEDataTables::DataElementParsers::DataBlock', type: :model do
  let(:headers) do
    %i[npd_alias field_reference old_alias years_populated description values
       collection_term tier_of_variable available_from_udks identification_risk
       sensitivity data_request_data_item_required data_request_years_required]
  end

  let(:block) do
    {
      header_row: 5,
      first_row: nil,
      last_row: 12,
      table_name: 'census'
    }
  end

  subject do
    workbook_path = 'spec/fixtures/files/simple_table.xlsx'
    workbook = Roo::Spreadsheet.open(workbook_path)
    sheet = workbook.sheet_for('census')
    DfEDataTables::DataElementParsers::DataBlock.new(sheet, 'census', block)
  end

  it 'will have the block data' do
    expect(subject.header_row).to eq(block[:header_row])
    expect(subject.first_row).to eq(6)
    expect(subject.last_row).to eq(block[:last_row])
    expect(subject.table_name).to eq(block[:table_name])
  end

  it 'will map the headers' do
    expect(subject.headers).to eq(headers)
  end
end
