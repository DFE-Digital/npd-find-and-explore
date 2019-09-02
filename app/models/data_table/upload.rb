# frozen_string_literal: true

module DataTable
  class Upload < ApplicationRecord
    include DataElementImport
    include ProcessUpload

    default_scope { order(created_at: :asc) }

    belongs_to :admin_user, inverse_of: :dfe_data_tables, optional: true
    has_many :data_table_tabs,
             class_name: 'DataTable::Tab', foreign_key: :data_table_upload_id,
             inverse_of: :data_table_upload, dependent: :destroy
    has_many :data_table_rows,
             class_name: 'DataTable::Row', foreign_key: :data_table_upload_id,
             inverse_of: :data_table_upload, dependent: :destroy

    has_one_attached :data_table

    def initialize(attr)
      init_data_table_workbook(attr.delete(:data_table))
      super(attr)
    end

    def new_rows
      DataTable::Row.joins('LEFT OUTER JOIN data_elements ON data_table_rows.npd_alias = data_elements.npd_alias')
                    .where(data_table_rows: { data_table_upload_id: id })
                    .where(data_elements: { npd_alias: nil })
                    .pluck(:npd_alias).uniq
    end
  end
end
