# frozen_string_literal: true

require 'active_support/concern'

module ProcessUpload
  extend ActiveSupport::Concern

  included do
    def preprocess
      save
      rows = []
      upload_errors = []
      upload_warnings = []
      tabs_to_process.compact.each do |tab|
        tab_rows = tab.preprocess do |el|
          el.merge('data_table_tab_id' => tab.id, 'data_table_upload_id' => id,
                   'concept_id' => no_concept.id)
        end

        rows.concat(tab_rows.uniq { |r| r[:unique_alias] || r['unique_alias'] })
        upload_errors.concat(tab.process_errors) if tab.process_errors&.any?
        upload_warnings.concat(tab.process_warnings) if tab.process_warnings&.any?
      end
      update(upload_errors: upload_errors.flatten, upload_warnings: upload_warnings.flatten)
      import_elements(DataTable::Row, rows.compact.flatten)
    end

    def process
      Rails.logger.info "Uploading #{file_name}"
      DataElement.skip_indexing = true

      import_elements(DataElement, data_table_rows.map(&:to_data_element_hash).uniq { |r| r[:unique_alias] })
      DataElement.where(id: del_rows.pluck(:id)).destroy_all
      del_datasets.each { |ds| ds.data_elements.clear }
      import_datasets(id)

      DataElement.skip_indexing = false
      DataElement.rebuild_pg_search_documents

      Rails.logger.info "Uploaded #{file_name}"
      update(successful: true)

      true
    end

  private

    def tabs_to_process
      @tabs_to_process ||= workbook.sheets.map do |tab|
        DataTable::Tab.create!(data_table_upload: self,
                               workbook: workbook, tab_name: tab)
      end
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
