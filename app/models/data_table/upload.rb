# frozen_string_literal: true

module DataTable
  class Upload < ApplicationRecord
    include Preprocess

    default_scope { order(created_at: :asc) }

    belongs_to :admin_user, inverse_of: :dfe_data_tables, optional: true
    has_many :data_table_tabs,
             class_name: 'DataTable::Tab', foreign_key: :data_table_upload_id,
             inverse_of: :data_table_upload, dependent: :destroy

    has_one_attached :data_table
  end
end
