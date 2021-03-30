# frozen_string_literal: true

module Admin
  class UploadsController < Admin::ApplicationController
    layout 'admin/application'

    def index
      custom_breadcrumbs_for(admin: true,
                             leaf: I18n.translate('admin.uploads.breadcrumbs'))

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
  end
end
