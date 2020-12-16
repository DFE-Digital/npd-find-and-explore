# frozen_string_literal: true

require 'active_support/concern'

module ProcessUpload
  extend ActiveSupport::Concern

  included do
    def preprocess
      save
      rows = []

      tabs_to_process.compact.each do |tab|
        next if tab.dataset.nil?

        rows.concat(preprocess_tab(tab))
      end

      import_elements(DataTable::Row, rows.compact.flatten)
    end

    def preprocess_unrecognised(form_params)
      rows = []

      workbook = Roo::Spreadsheet.open(
        ActiveStorage::Blob.service.send(:path_for, data_table.key),
        extension: File.extname(data_table.record.file_name).gsub(/^\./, '').to_sym
      )

      form_params
        .select { |_k, v| %w[create match].include?(v[:action]) }
        .each do |key, tab_params|
        tab = data_table_tabs.find_by(id: key)
        dataset = find_or_create_dataset(tab, tab_params)
        tab.update(dataset_id: dataset.id, selected: true)

        tab.restore_sheet(workbook: workbook)
        rows.concat(preprocess_tab(tab))
      end

      import_elements(DataTable::Row, rows.compact.flatten)
    end

    def process
      Rails.logger.info "Uploading #{file_name}"
      DataElement.skip_indexing = true

      import_elements(
        DataElement,
        data_table_rows.selected.importable.map(&:to_data_element_hash).uniq { |r| r[:unique_alias] }
      )
      import_datasets(id)

      DataElement.skip_indexing = false
      DataElement.rebuild_pg_search_documents

      Rails.logger.info "Uploaded #{file_name}"
      update(successful: true)

      true
    end

  private

    def preprocess_tab(tab)
      upload_errors = []
      upload_warnings = []
      tab_rows = tab.preprocess do |el|
        el.merge('data_table_tab_id' => tab.id, 'data_table_upload_id' => id,
                 'concept_id' => no_concept.id)
      end

      upload_errors.concat(tab.process_errors) if tab.process_errors&.any?
      upload_warnings.concat(tab.process_warnings) if tab.process_warnings&.any?

      update(upload_errors: upload_errors.flatten, upload_warnings: upload_warnings.flatten)

      tab_rows.uniq { |r| r[:unique_alias] || r['unique_alias'] }
    end

    def find_or_create_dataset(tab, tab_params)
      dataset_id = tab_params.dig(:match_dataset_id)
      dataset = nil
      if dataset_id.present?
        dataset = Dataset.find_by(id: dataset_id)
        dataset.update(tab_name: tab.tab_name,
                       tab_regex: tab.tab_name,
                       first_row_regex: '---')
      else
        dataset = Dataset.create(tab_name: tab.tab_name,
                                 headers_regex: tab_params.dig(:new_dataset_alias),
                                 name: tab_params.dig(:new_dataset_name),
                                 description: tab_params.dig(:new_dataset_desc),
                                 tab_regex: tab.tab_name,
                                 first_row_regex: '---',
                                 imported: true)
      end
      dataset
    end

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
