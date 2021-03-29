# frozen_string_literal: true

module Admin
  class DatasetsController < Admin::ApplicationController
    layout :layout_by_resource

    before_action :generate_breadcrumbs, only: %i[index]

    def destroy
      requested_resource.data_table_tabs.destroy_all
      requested_resource
        .data_elements
        .select { |data_element| data_element.datasets.count < 2 }
        .each(&:destroy)

      if requested_resource.destroy
        flash[:notice] = translate_with_resource('destroy.success')
      else
        flash[:error] = requested_resource.errors.full_messages.join('<br/>')
      end
      redirect_to action: :index
    end

  private

    def layout_by_resource
      if %w[index].include?(params[:action])
        'admin/application'
      else
        'admin/side_menu'
      end
    end

    def generate_breadcrumbs
      custom_breadcrumbs_for(admin: true,
                             leaf: params[:id].present? ? requested_resource.name : I18n.translate('admin.datasets.title'))
    end
  end
end
