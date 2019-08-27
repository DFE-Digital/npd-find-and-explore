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

    def preprocess
      upload_errors = []
      upload_warnings = []
      tabs_to_process.each do |tab|
        tab.preprocess { |element| element.merge('concept_id' => no_concept.id) }
        upload_errors << tab.process_errors if tab.process_errors&.any?
        upload_warnings << tab.process_warnings if tab.process_warnings&.any?
      end
      update(upload_errors: upload_errors.flatten, upload_warnings: upload_warnings.flatten)
    end

    def process
      # For each worksheet
      data_table_tabs.each do |tab|
        Rails.logger.info "Uploading #{tab.tab_name}"

        import_elements(tab.rows)

        Rails.logger.info "Uploaded #{tab.tab_name}"
      end
      update(successful: true)

      true
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

    def tabs_to_process
      @tabs_to_process ||= SHEETS.map { |tab| tab.new(data_table_upload: self, workbook: data_tables_workbook) }
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

    def no_concept
      @no_concept ||= Concept.find_or_create_by(name: 'No Concept', category: no_category)
    end

    def no_category
      @no_category ||= Category.find_or_create_by(name: 'No Category')
    end
  end
end
