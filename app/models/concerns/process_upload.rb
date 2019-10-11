# frozen_string_literal: true

require 'active_support/concern'

module ProcessUpload
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

    attr_accessor :tab_name

    def preprocess
      save
      rows = []
      upload_errors = []
      upload_warnings = []
      tabs_to_process.each do |tab|
        tab_rows = tab.preprocess { |el| el.merge('concept_id' => no_concept.id, 'data_table_upload_id' => id) }
        rows.concat(tab_rows)
        upload_errors.concat(tab.process_errors) if tab.process_errors&.any?
        upload_warnings.concat(tab.process_warnings) if tab.process_warnings&.any?
      end
      update(upload_errors: upload_errors.flatten, upload_warnings: upload_warnings.flatten)
      import_elements(DataTable::Row, rows.compact.flatten.uniq { |r| r[:npd_alias] || r['npd_alias'] })
    end

    def process
      # For each worksheet
      Rails.logger.info "Uploading #{file_name}"

      import_elements(DataElement, data_table_rows.map(&:to_data_element_hash))
      DataElement.where(id: del_rows.pluck(:id)).destroy_all

      Rails.logger.info "Uploaded #{file_name}"
      update(successful: true)

      true
    end

  private

    def tabs_to_process
      @tabs_to_process ||= SHEETS.map { |tab| tab.create(data_table_upload: self, workbook: workbook) }
    end

    def no_concept
      @no_concept ||= Concept.find_or_create_by(name: 'No Concept', category: no_category) do |concept|
        concept.description = 'This Concept is used to house data elements that are waiting to be categorised'
      end
    end

    def no_category
      @no_category ||= Category.find_or_create_by(name: 'No Category')
    end
  end
end
