# frozen_string_literal: true

module Admin
  class DataElementsController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # you can overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = DataElement.
    #     page(params[:page]).
    #     per(10)
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   DataElement.find_by!(slug: param)
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information

    def import
      @last_import = DfEDataTable.order(created_at: :asc).last
      render :import, layout: 'admin/application', locals: { success: nil, error: '' }
    end

    def do_import
      if params['file-upload'].blank?
        @last_import = DfEDataTable.order(created_at: :asc).last
        render partial: 'form', layout: false, locals: { success: false, error: 'Please upload a file' }
        return
      end

      unless DfEDataTables::UPLOAD_CONTENT_TYPES.include?(params['file-upload'].content_type)
        @last_import = DfEDataTable.order(created_at: :asc).last
        render partial: 'form', layout: false, locals: { success: false, error: 'Wrong format. Please upload an Excel spreadsheet' }
        return
      end

      DfEDataTables::DataElementsLoader.new(params['file-upload'])
      DfEDataTable.create(admin_user: current_admin_user,
                          file_name: params['file-upload'].original_filename,
                          data_table: params['file-upload'])

      @last_import = DfEDataTable.order(created_at: :asc).last

      render partial: 'form', layout: false, locals: { success: true, error: '' }
    rescue StandardError => error
      Rails.logger.error(error)
      @last_import = DfEDataTable.order(created_at: :asc).last

      render partial: 'form', layout: false, locals: { success: false, error: 'There has been an error while processing your file' }
    end
  end
end
