# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DfEDataTables::DataElementParsers::Sheet', type: :model do
  let(:concept) { build :concept }
  let(:workbook_path) { 'spec/fixtures/files/single_sheet_table.xlsx' }
  let(:workbook) { Roo::Spreadsheet.open(workbook_path) }
  let(:spreadsheet) { DfEDataTables::DataElementParsers::Sheet.new(workbook) }

  it 'Will extract the sheet_name from table' do
    expect(spreadsheet.sheet_name).to eq('census')
  end

  it 'Will extract the sheet from table' do
    expect(spreadsheet.sheet.class.name).to eq('Roo::Excelx::Sheet')
  end

  it 'Will load the file and create the Sheet object under 50ms' do
    expect {
      workbook = Roo::Spreadsheet.open(workbook_path)
      DfEDataTables::DataElementParsers::Sheet.new(workbook)
    }.to perform_under(50).ms.sample(10)
  end

  it 'Will peform a lot better (just under 1000ms) if it bulk saves' do
    table = spreadsheet
    expect {
      DataElement.import(table.map { |element| element[:concept_id] = concept.id },
                         on_duplicate_key_update: %i[source_table_name source_attribute_name])
    }.to perform_under(1000).ms.sample(10)
  end
end
