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

        elements = sheet_parser.map do |element|
          element[:concept_id] = concept.id
          element
        end
        DataElement.import(elements, on_duplicate_key_update: %i[source_table_name source_attribute_name])

        puts "Uploaded #{sheet_parser.sheet_name}"
      end

      true
    end

    def concept
      @concept ||= Concept.find_or_create_by(name: 'No Concept', category: category)
    end

    def category
      @category ||= Category.find_or_create_by(name: 'No Category')
    end
  end
end
