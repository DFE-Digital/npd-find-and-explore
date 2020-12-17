# frozen_string_literal: true

# All Administrate controllers inherit from this `Admin::ApplicationController`,
# making it the ideal place to put authentication logic or other
# before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module Admin
  class ApplicationController < Administrate::ApplicationController
    before_action :authenticate_admin_user!

    helper AdministrateMenuHelper
    include AdminControllerHelper
    # Override this value to specify the number of elements to display at a time
    # on index pages. Defaults to 20.
    # def records_per_page
    #   params[:per_page] || 20
    # end

    def destroy
      if requested_resource.destroy
        flash[:notice] = translate_with_resource('destroy.success')
      else
        flash[:error] = requested_resource.errors.full_messages.join('<br/>')
      end
      redirect_to action: :index
    rescue ActiveRecord::NotNullViolation => e
      flash[:error] = e.message
      redirect_to action: :index
    end

  private

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
  end
end
