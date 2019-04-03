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

  it 'Will perform under 550ms' do
    table = spreadsheet
    expect {
      table.map do |data_element|
        # do nothing
      end
    }.to perform_under(550).ms.sample(10)
  end

  it 'Will peform significantly slower (just under 12650ms) if needs saving' do
    table = spreadsheet
    expect {
      table.map do |data_element|
        next if data_element.nil?

        element = DataElement.find_or_create_by(find_params(data_element))
        element.update(update_params(data_element))
      end
    }.to perform_under(12650).ms.sample(10)
  end

  it 'Will peform a lot better (just under 1000ms) if it bulk saves' do
    table = spreadsheet
    expect {
      DataElement.import(table.map { |element| element[:concept_id] = concept.id },
                         on_duplicate_key_update: %i[source_table_name source_attribute_name])
    }.to perform_under(1000).ms.sample(10)
  end

private

  def find_params(data_element, concept = nil)
    {
      source_table_name: data_element[:source_table_name],
      source_attribute_name: data_element[:source_attribute_name],
      concept: data_element[:concept] || concept
    }
  end

  def update_params(data_element)
    {
      source_old_attribute_name: data_element[:source_old_attribute_name],
      identifiability: data_element[:identifiability],
      sensitivity: data_element[:sensitivity],
      academic_year_collected_from: data_element[:academic_year_collected_from],
      academic_year_collected_to: data_element[:academic_year_collected_to],
      collection_terms: data_element[:collection_terms],
      values: data_element[:values],
      description: data_element[:description],
      additional_attributes: data_element[:additional_attributes]
    }
  end
end
