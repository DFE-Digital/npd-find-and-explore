# frozen_string_literal: true

module DataTable
  class Row < ApplicationRecord
    belongs_to :data_table_upload, class_name: 'DataTable::Upload', inverse_of: :data_table_rows
    belongs_to :data_table_tab,    class_name: 'DataTable::Tab',    inverse_of: :data_table_rows

    def to_data_element_hash
      {
        id: id,
        concept_id: concept_id,
        npd_alias: npd_alias,
        source_table_name: source_table_name,
        source_attribute_name: source_attribute_name,
        source_old_attribute_name: source_old_attribute_name,
        additional_attributes: additional_attributes,
        identifiability: identifiability,
        sensitivity: sensitivity,
        academic_year_collected_from: academic_year_collected_from,
        academic_year_collected_to: academic_year_collected_to,
        standard_extract: standard_extract,
        is_cla: is_cla,
        collection_terms: collection_terms,
        educational_phase: educational_phase,
        data_type: data_type,
        values: values,
        description_en: description_en,
        description_cy: description_cy,
        created_at: created_at,
        updated_at: updated_at
      }
    end
  end
end
