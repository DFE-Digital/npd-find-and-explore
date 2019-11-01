# frozen_string_literal: true

module Admin
  class UploadsController < Admin::ApplicationController
    def index
      DataTable::Upload.where.not(successful: true).destroy_all
      DataTable::Upload.order(created_at: :desc).offset(5).destroy_all
      InfArch::Upload.where.not(successful: true).destroy_all
      InfArch::Upload.order(created_at: :desc).offset(5).destroy_all

      @data_table_uploads = DataTable::Upload.where(successful: true).order(created_at: :desc)
      @inf_arch_uploads = InfArch::Upload.where(successful: true).order(created_at: :desc)
    end
  end
end
