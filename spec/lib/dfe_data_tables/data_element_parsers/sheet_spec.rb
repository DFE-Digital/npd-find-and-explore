# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DfEDataTables::DataElementParsers::Sheet', type: :model do
  subject do
    workbook_path = 'spec/fixtures/files/simple_table.xlsx'
    workbook = Roo::Spreadsheet.open(workbook_path)
    DfEDataTables::DataElementParsers::Sheet.new(workbook)
  end

  it 'will extract the sheet_name from table' do
    expect(subject.sheet_name).to eq('census')
  end

  it 'will extract the sheet from table' do
    expect(subject.sheet.class.name).to eq('Roo::Excelx::Sheet')
  end
end
