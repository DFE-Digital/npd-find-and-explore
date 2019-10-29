# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataTable::Tab, type: :model do
  let(:concept) { build :concept }
  let(:workbook_path) { 'spec/fixtures/files/single_sheet_table.xlsx' }
  let(:workbook) { Roo::Spreadsheet.open(workbook_path) }
  let(:tab) { DataTable::Tab.new(workbook: workbook) }
  let(:wrong_workbook_path) { 'spec/fixtures/files/single_sheet_table_wrong_name.xlsx' }
  let(:wrong_workbook) { Roo::Spreadsheet.open(wrong_workbook_path) }
  let(:wrong_tab) { DataTable::Tab.new(workbook: wrong_workbook) }

  it 'Will extract the tab_name from table model' do
    expect(tab.tab_name).to eq('Tab')
  end

  it 'Will extract the sheet from table' do
    expect(tab.sheet.class.name).to eq('Roo::Excelx::Sheet')
  end

  it 'Will error if the tab is not in the file' do
    expect(wrong_tab.process_warnings).to eq(["Can't find tab Tab in the uploaded file"])
  end

  it 'Will load the file and create the Sheet object under 40ms' do
    expect {
      workbook = Roo::Spreadsheet.open(workbook_path)
      DataTable::Tab.new(workbook: workbook)
    }.to perform_under(40).ms.sample(10)
  end

  it 'Will preprocess under 100ms' do
    expect { tab.preprocess }
      .to perform_under(100).ms.sample(10)
  end
end
