# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataTable::Tab, type: :model do
  let(:concept) { build :concept }
  let(:workbook_path) { 'spec/fixtures/files/single_sheet_table.xlsx' }
  let(:workbook) { Roo::Spreadsheet.open(workbook_path) }
  let(:tab) { DataTable::Tab.new(workbook: workbook, tab_name: 'KS4') }
  let(:wrong_workbook_path) { 'spec/fixtures/files/single_sheet_table_wrong_name.xlsx' }
  let(:wrong_workbook) { Roo::Spreadsheet.open(wrong_workbook_path) }
  let(:no_tab_name) { DataTable::Tab.new(workbook: wrong_workbook) }
  let(:wrong_tab) { DataTable::Tab.new(workbook: wrong_workbook, tab_name: 'KS4') }
  let(:new_tab) do
    workbook = Roo::Spreadsheet.open(workbook_path)
    DataTable::Tab.new(workbook: workbook)
  end

  before do
    Rails.configuration.datasets.each do |dataset|
      Dataset.find_or_create_by!(tab_name: dataset['tab_name'],
                                 name: dataset['name'],
                                 description: dataset['description'],
                                 tab_regex: dataset['tab_regex'],
                                 headers_regex: dataset['headers_regex'],
                                 first_row_regex: dataset['first_row_regex'])
    end
  end

  it 'Will extract the tab_name from the dataset' do
    expect(tab.dataset.tab_name).to eq('KS4')
  end

  it 'Will extract the sheet from table' do
    expect(tab.sheet.class.name).to eq('Roo::Excelx::Sheet')
  end

  it 'Will error if no tab name is provided' do
    expect(no_tab_name.process_warnings).to eq(['No tab name provided'])
  end

  it 'Will error if the tab is not in the file' do
    expect(wrong_tab.process_warnings).to eq(['Can\'t find tab KS4 in the uploaded file'])
  end

  it 'Will load the file and create the Sheet object under 40ms' do
    expect { new_tab }.to perform_under(40).ms.sample(10)
  end

  it 'Will preprocess under 110ms' do
    expect { tab.preprocess }
      .to perform_under(110).ms.sample(10)
  end
end
