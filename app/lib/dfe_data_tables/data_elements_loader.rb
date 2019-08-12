# frozen_string_literal: true

module DfEDataTables
  # Load DataElements from the spreadhseet
  class DataElementsLoader
    SHEETS = [
      DfEDataTables::DataElementParsers::ScPupil,
      DfEDataTables::DataElementParsers::ScAddresses,
      DfEDataTables::DataElementParsers::PruCensus,
      DfEDataTables::DataElementParsers::EarlyYearsCensus,
      DfEDataTables::DataElementParsers::AltProvision,
      DfEDataTables::DataElementParsers::ApAddresses,
      DfEDataTables::DataElementParsers::Eyfsp,
      DfEDataTables::DataElementParsers::Phonics,
      DfEDataTables::DataElementParsers::Ks1,
      DfEDataTables::DataElementParsers::Ks2,
      DfEDataTables::DataElementParsers::Year7,
      DfEDataTables::DataElementParsers::Ks3,
      DfEDataTables::DataElementParsers::Ks4,
      DfEDataTables::DataElementParsers::Ks5,
      DfEDataTables::DataElementParsers::Cin,
      DfEDataTables::DataElementParsers::Cla,
      DfEDataTables::DataElementParsers::Absence,
      DfEDataTables::DataElementParsers::ExclusionsUpTo2005,
      DfEDataTables::DataElementParsers::ExclusionsFrom2005,
      DfEDataTables::DataElementParsers::Plams,
      DfEDataTables::DataElementParsers::Nccis,
      DfEDataTables::DataElementParsers::Isp,
      DfEDataTables::DataElementParsers::Ypmad
    ].freeze

    attr_reader :errors

    def initialize(data_tables_path)
      @data_tables_workbook = Roo::Spreadsheet.open(data_tables_path)
      @sheets_to_process = SHEETS.map { |sheet| sheet.new(@data_tables_workbook) }
      @errors = []
    end

    def preprocess
      @sheets_to_process.each do |sheet|
        sheet.check_headers
        @errors << sheet.errors if sheet.errors.any?
      end
    end

    def process
      sheet_name = nil
      # For each worksheet
      @sheets_to_process.each do |sheet_parser|
        sheet_name = sheet_parser.sheet_name
        Rails.logger.info "Uploading #{sheet_parser.sheet_name}"

        elements = sheet_parser.map { |element| element.merge(concept_id: concept.id) }
                               .uniq { |element| element.dig(:npd_alias) }

        import_elements(elements)

        Rails.logger.info "Uploaded #{sheet_parser.sheet_name}"
      end

      @data_tables_workbook.close
      true
    rescue StandardError
      Rails.logger.error "An error happened while uploading #{sheet_name}"
      @data_tables_workbook.close
    end

  private

    COLUMNS = %i[source_table_name source_attribute_name additional_attributes
                 identifiability sensitivity source_old_attribute_name
                 academic_year_collected_from academic_year_collected_to
                 collection_terms values description_en description_cy data_type
                 educational_phase updated_at].freeze

    def import_elements(elements)
      DataElement.import(
        elements,
        on_duplicate_key_update: {
          conflict_target: %i[npd_alias],
          columns: COLUMNS
        }
      )
    end

    def concept
      @concept ||= Concept.find_or_create_by(name: 'No Concept', category: category) do |new_concept|
        new_concept.description = 'No Description'
      end
    end

    def category
      @category ||= Category.find_or_create_by(name: 'No Category')
    end
  end
end
