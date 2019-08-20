# frozen_string_literal: true

require 'active_support/concern'

module Preprocess
  extend ActiveSupport::Concern

  included do
    SHEETS = [
      DataTable::ScPupil,
      DataTable::ScAddresses,
      DataTable::PruCensus,
      DataTable::EarlyYearsCensus,
      DataTable::AltProvision,
      DataTable::ApAddresses,
      DataTable::Eyfsp,
      DataTable::Phonics,
      DataTable::Ks1,
      DataTable::Ks2,
      DataTable::Year7,
      DataTable::Ks3,
      DataTable::Ks4,
      DataTable::Ks5,
      DataTable::Cin,
      DataTable::Cla,
      DataTable::Absence,
      DataTable::ExclusionsUpTo2005,
      DataTable::ExclusionsFrom2005,
      DataTable::Plams,
      DataTable::Nccis,
      DataTable::Isp,
      DataTable::Ypmad
    ].freeze

    attr_accessor :data_tables_workbook, :tab_name

    def initialize(attr)
      init_data_table_workbook(attr[:data_table])
      super(attr)
    end

    def preprocess
      upload_errors = []
      upload_warnings = []
      sheets_to_process.each do |sheet|
        sheet.check_headers
        upload_errors << sheet.process_errors if sheet.process_errors&.any?
        upload_warnings << sheet.process_warnings if sheet.process_warnings&.any?
        sheet.check_rows
        sheet.save
      end
      update(upload_errors: upload_errors.flatten, upload_warnings: upload_warnings.flatten, successful: upload_errors.none?)
    end

    def process
      # For each worksheet
      data_table_tabs.each do |sheet_parser|
        tab_name = sheet_parser.tab_name
        Rails.logger.info "Uploading #{sheet_parser.tab_name}"

        elements = sheet_parser.map { |element| element.merge(concept_id: concept.id) }
                               .uniq { |element| element.dig(:npd_alias) }

        import_elements(elements)

        Rails.logger.info "Uploaded #{sheet_parser.tab_name}"
      end

      true
    rescue StandardError
      Rails.logger.error "An error happened while uploading #{tab_name}"
      false
    end

  private
    COLUMNS = %i[source_table_name source_attribute_name additional_attributes
                 identifiability sensitivity source_old_attribute_name
                 academic_year_collected_from academic_year_collected_to
                 collection_terms values description_en description_cy data_type
                 educational_phase updated_at].freeze

    def init_data_table_workbook(file)
      @data_tables_workbook = Roo::Spreadsheet.open(file)
    end

    def sheets_to_process
      @sheets_to_process ||= SHEETS.map { |sheet| sheet.new(data_table_upload: self, workbook: data_tables_workbook) }
    end

    def import_elements(elements)
      DataElement.import(
        elements,
        on_duplicate_key_update: {
          conflict_target: %i[npd_alias],
          columns: COLUMNS
        }
      )
    end
  end
end
