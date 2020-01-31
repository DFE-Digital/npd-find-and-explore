# frozen_string_literal: true

module Admin
  class UploadsController < Admin::ApplicationController
    def index
      trim_data_table_uploads
      trim_inf_arch_uploads

      @data_table_uploads = DataTable::Upload
        .where(successful: true)
        .reorder(created_at: :desc)
        .includes(%i[admin_user])
      @inf_arch_uploads = InfArch::Upload
        .where(successful: true)
        .reorder(created_at: :desc)
        .includes(%i[admin_user])
    end

  private

    def trim_data_table_uploads
      DataTable::Upload.where.not(successful: true).reorder(created_at: :desc).offset(5).destroy_all
      DataTable::Upload.where(successful: true).reorder(created_at: :desc).offset(5).destroy_all
    end

    def trim_inf_arch_uploads
      InfArch::Upload.where.not(successful: true).reorder(created_at: :desc).offset(5).destroy_all
      InfArch::Upload.where(successful: true).reorder(created_at: :desc).offset(5).destroy_all
    end
  end
end
