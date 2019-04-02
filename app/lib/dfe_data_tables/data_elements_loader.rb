# frozen_string_literal: true

module DfEDataTables
  # Load DataElements from the spreadhseet
  class DataElementsLoader
    def initialize(data_tables_path)
      data_tables_workbook = Roo::Spreadsheet.open(data_tables_path)

      @sheets_to_process = [
        DfEDataTables::DataElementParsers::ScPupil.new(data_tables_workbook),
        DfEDataTables::DataElementParsers::ScAddresses.new(data_tables_workbook),
        DfEDataTables::DataElementParsers::PruCensus.new(data_tables_workbook),
        DfEDataTables::DataElementParsers::EarlyYearsCensus.new(data_tables_workbook),
        DfEDataTables::DataElementParsers::AltProvision.new(data_tables_workbook),
        DfEDataTables::DataElementParsers::ApAddresses.new(data_tables_workbook),
        DfEDataTables::DataElementParsers::Eyfsp.new(data_tables_workbook),
        DfEDataTables::DataElementParsers::Phonics.new(data_tables_workbook),
        DfEDataTables::DataElementParsers::Ks1.new(data_tables_workbook),
        DfEDataTables::DataElementParsers::Ks2.new(data_tables_workbook),
        DfEDataTables::DataElementParsers::Year7.new(data_tables_workbook),
        DfEDataTables::DataElementParsers::Ks3.new(data_tables_workbook),
        DfEDataTables::DataElementParsers::Ks4.new(data_tables_workbook),
        DfEDataTables::DataElementParsers::Ks5.new(data_tables_workbook),
        DfEDataTables::DataElementParsers::Cin.new(data_tables_workbook),
        DfEDataTables::DataElementParsers::Cla.new(data_tables_workbook),
        DfEDataTables::DataElementParsers::Absence.new(data_tables_workbook),
        DfEDataTables::DataElementParsers::ExclusionsUpTo2005.new(data_tables_workbook),
        DfEDataTables::DataElementParsers::ExclusionsFrom2005.new(data_tables_workbook),
        DfEDataTables::DataElementParsers::Plams.new(data_tables_workbook),
        DfEDataTables::DataElementParsers::Nccis.new(data_tables_workbook),
        DfEDataTables::DataElementParsers::Isp.new(data_tables_workbook),
        DfEDataTables::DataElementParsers::Ypmad.new(data_tables_workbook)
      ]

      process
    end

  private

    def process
      # For each worksheet
      @sheets_to_process.each do |sheet_parser|
        puts "Uploading #{sheet_parser.sheet_name}"

        sheet_parser.parse_each do |data_element|
          next if data_element.empty?

          element = DataElement.find_or_create_by(find_params(data_element))

          element.update(update_params(element, data_element))
        end

        puts "Uploaded #{sheet_parser.sheet_name}"
      end

      true
    end

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

    def concept
      @concept ||= Concept.find_or_create_by(name: 'No Concept', category: category)
    end

    def category
      @category ||= Category.find_or_create_by(name: 'No Category')
    end
  end
end
