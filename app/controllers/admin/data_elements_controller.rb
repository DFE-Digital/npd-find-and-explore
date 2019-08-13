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
      error = check_input_file
      if error
        render partial: 'form', layout: false, locals: { success: false, error: error }
        return
      end

      loader.preprocess

      if loader.errors.any?
        render partial: 'form', layout: false, locals: { success: false, error: loader.errors.join(', ') }
        return
      end

      load_tables
      render partial: 'form', layout: false, locals: { success: true, error: '' }
    rescue StandardError => error
      Rails.logger.error(error)
      @last_import = DfEDataTable.order(created_at: :asc).last

      render partial: 'form', layout: false, locals: { success: false, error: 'There has been an error while processing your file' }
    end

  private

    def check_input_file
      @last_import = DfEDataTable.order(created_at: :asc).last

      return 'Please upload a file' if params['file-upload'].blank?
      return 'Wrong format. Please upload an Excel spreadsheet' unless DfEDataTables::UPLOAD_CONTENT_TYPES.include?(params['file-upload'].content_type)

      nil
    end

    def loader
      @loader ||= DfEDataTables::DataElementsLoader.new(params['file-upload'])
    end

    def load_tables
      loader.process

      DfEDataTable.create(admin_user: current_admin_user,
                          file_name: params['file-upload'].original_filename,
                          data_table: params['file-upload'])

      @last_import = DfEDataTable.order(created_at: :asc).last
    end
  end
end
