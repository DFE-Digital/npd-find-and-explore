# frozen_string_literal: true

module DfEDataTables
  class Loader
    def initialize(data_tables_path)
      data_tables_workbook = Roo::Spreadsheet.open(data_tables_path)

      @sheets_to_process = [
        DfEDataTables::Parsers::ScPupil.new(data_tables_workbook).to_h,
        DfEDataTables::Parsers::ScAddresses.new(data_tables_workbook).to_h,
        DfEDataTables::Parsers::PruCensus.new(data_tables_workbook).to_h,
        DfEDataTables::Parsers::EarlyYearsCensus.new(data_tables_workbook).to_h,
        DfEDataTables::Parsers::AltProvision.new(data_tables_workbook).to_h,
        DfEDataTables::Parsers::ApAddresses.new(data_tables_workbook).to_h,
        DfEDataTables::Parsers::Eyfsp.new(data_tables_workbook).to_h,
        DfEDataTables::Parsers::Phonics.new(data_tables_workbook).to_h,
        DfEDataTables::Parsers::Ks1.new(data_tables_workbook).to_h,
        DfEDataTables::Parsers::Ks2.new(data_tables_workbook).to_h,
        DfEDataTables::Parsers::Year7.new(data_tables_workbook).to_h,
        DfEDataTables::Parsers::Ks3.new(data_tables_workbook).to_h,
        DfEDataTables::Parsers::Ks4.new(data_tables_workbook).to_h,
        DfEDataTables::Parsers::Ks5.new(data_tables_workbook).to_h,
        DfEDataTables::Parsers::Cin.new(data_tables_workbook).to_h,
        DfEDataTables::Parsers::Cla.new(data_tables_workbook).to_h,
        DfEDataTables::Parsers::Absence.new(data_tables_workbook).to_h,
        DfEDataTables::Parsers::ExclusionsUpTo2005.new(data_tables_workbook).to_h,
        DfEDataTables::Parsers::ExclusionsFrom2005.new(data_tables_workbook).to_h,
        DfEDataTables::Parsers::Plams.new(data_tables_workbook).to_h,
        DfEDataTables::Parsers::Nccis.new(data_tables_workbook).to_h,
        DfEDataTables::Parsers::Isp.new(data_tables_workbook).to_h,
        DfEDataTables::Parsers::Ypmad.new(data_tables_workbook).to_h
      ]
    end
  end
end
