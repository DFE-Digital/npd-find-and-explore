# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DfEDataTables::DataElementParsers::Sheet', type: :model do
  let(:concept) { build :concept }
  let(:workbook_path) { 'spec/fixtures/files/simple_table.xlsx' }
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
    }.to perform_under(50).ms.sample(5)
  end

  it 'Will perform under a 80ms' do
    table = spreadsheet
    expect {
      table.parse_each do |data_element|
        # do nothing
      end
    }.to perform_under(80).ms.sample(5)
  end

  it 'Will peform significantly slower (just under 650ms) if needs saving' do
    table = spreadsheet
    expect {
      table.parse_each do |data_element|
        next if data_element.empty?

        element = DataElement.find_or_create_by(find_params(data_element))
        element.update(update_params(element, data_element))
      end
    }.to perform_under(650).ms.sample(5)
  end

private

  def find_params(data_element)
    {
      source_table_name: data_element.dig(:table_name),
      source_attribute_name: data_element.dig(:field_reference),
      concept: concept
    }
  end

  def update_params(element, data_element)
    {
      source_old_attribute_name: [data_element.dig(:old_alias), data_element.dig(:former_name)].flatten.compact,
      identifiability: data_element.dig(:identification_risk),
      sensitivity: data_element.dig(:sensitivity),
      academic_year_collected_from: data_element.dig(:years_populated, :from),
      academic_year_collected_to: data_element.dig(:years_populated, :to),
      collection_terms: data_element.dig(:collection_term),
      values: data_element.dig(:values),
      description: data_element.dig(:description),
      additional_attributes: (element.additional_attributes || {}).merge(data_element)
    }
  end
end
