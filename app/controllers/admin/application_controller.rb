# frozen_string_literal: true

# All Administrate controllers inherit from this `Admin::ApplicationController`,
# making it the ideal place to put authentication logic or other
# before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module Admin
  class ApplicationController < Administrate::ApplicationController
    layout 'admin/side_menu'
    before_action :authenticate_admin_user!

    helper AdministrateMenuHelper
    include AdminControllerHelper
    include BreadcrumbBuilder
    # Override this value to specify the number of elements to display at a time
    # on index pages. Defaults to 20.
    # def records_per_page
    #   params[:per_page] || 20
    # end

    def delete_confirmation
      requested_resource

      render :delete_confirmation,
             layout: 'admin/application',
             locals: {
             page: Administrate::Page::Form.new(dashboard, requested_resource)
      }
    end

    def destroy
      if params.dig(:delete) && params.dig(:delete) == 'no'
        flash[:notice] = translate_with_resource('destroy.aborted')
      elsif requested_resource.destroy
        flash[:notice] = translate_with_resource('destroy.success')
      else
        flash[:error] = requested_resource.errors.full_messages.join('<br/>')
      end
      redirect_to redirect_after_destroy
    rescue ActiveRecord::NotNullViolation => e
      flash[:error] = e.message
      redirect_to redirect_after_destroy
    end

  private

    def redirect_after_destroy
      if %w[admin/categories admin/concepts].include? params[:controller]
        { action: :childless }
      else
        { action: :index }
      end
    end

    def check_input_file
      raise(ArgumentError, 'Please upload a file') if params['file-upload'].blank?
      raise(ArgumentError, 'Wrong format. Please upload an Excel spreadsheet') unless DataTable.check_content_type(params['file-upload'])

      nil
    end

    def trim_inf_arch_uploads(count: 5)
      InfArch::Upload.where.not(successful: true).reorder(created_at: :desc).offset(count).destroy_all
      InfArch::Upload.where(successful: true).reorder(created_at: :desc).offset(count).destroy_all
    end

    def trim_data_table_uploads(count: 5)
      DataTable::Upload.where.not(successful: true).reorder(created_at: :desc).offset(count).each do |upload|
        upload&.fast_cleanup
        upload&.destroy
      end
      DataTable::Upload.where(successful: true).reorder(created_at: :desc).offset(count).each do |upload|
        upload&.fast_cleanup
        upload&.destroy
      end
    end

    def generate_back_breadcrumbs
      if params[:action] == 'show' && request.referrer.present? && %r{/edit} =~ request.referrer
        back_breadcrumbs path: redirect_after_destroy
      else
        back_breadcrumbs
      end
    end
  end
end
