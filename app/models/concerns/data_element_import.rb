# frozen_string_literal: true

require 'active_support/concern'

module DataElementImport
  extend ActiveSupport::Concern

  included do
  private

    COLUMNS = %i[source_table_name source_attribute_name additional_attributes
                 identifiability sensitivity source_old_attribute_name
                 academic_year_collected_from academic_year_collected_to
                 standard_extract is_cla collection_terms values description
                 data_type educational_phase updated_at].freeze

    def conflict_target(import_model)
      return %i[data_table_tab_id npd_alias] if import_model == DataTable::Row

      %i[npd_alias]
    end

    def import_elements(import_model, elements)
      return unless import_model.respond_to?(:import)

      import_model.import(
        elements,
        on_duplicate_key_update: {
          conflict_target: conflict_target(import_model),
          columns: COLUMNS
        }
      )
    end

    def import_datasets(upload_id)
      conn = ActiveRecord::Base.connection
      conn.execute <<-SQL
        INSERT INTO data_elements_datasets (data_element_id, dataset_id)
        SELECT data_elements.id, datasets.id
        FROM data_table_rows
        LEFT OUTER JOIN data_elements ON data_table_rows.npd_alias = data_elements.npd_alias
        LEFT OUTER JOIN data_table_tabs ON data_table_rows.data_table_tab_id = data_table_tabs.id
        LEFT OUTER JOIN datasets ON data_table_tabs.type = datasets.tab_type
        WHERE data_table_rows.data_table_upload_id = #{conn.quote(upload_id)}
        AND data_elements.id IS NOT NULL
        AND datasets.id IS NOT NULL
        ON CONFLICT (data_element_id, dataset_id)
        DO NOTHING
      SQL
    end
  end
end
