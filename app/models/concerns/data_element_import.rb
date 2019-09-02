# frozen_string_literal: true

require 'active_support/concern'

module DataElementImport
  extend ActiveSupport::Concern

  included do
  private

    COLUMNS = %i[source_table_name source_attribute_name additional_attributes
                 identifiability sensitivity source_old_attribute_name
                 academic_year_collected_from academic_year_collected_to
                 collection_terms values description_en description_cy data_type
                 educational_phase updated_at].freeze

    def conflict_target(import_model)
      return %i[data_table_upload_id npd_alias] if import_model == DataTable::Row

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
  end
end
