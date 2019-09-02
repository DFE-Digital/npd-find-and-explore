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
      @last_import = DataTable::Upload.where(successful: true).order(created_at: :asc).last
      render :import, layout: 'admin/application', locals: { success: nil, error: '' }
    end

    def preprocess
      @last_import = DataTable::Upload.where(successful: true).order(created_at: :asc).last
      check_input_file
      loader = DataTable::Upload.new(admin_user: current_admin_user,
                                     file_name: params['file-upload'].original_filename,
                                     data_table: params['file-upload'])
      loader.preprocess

      render partial: 'preprocess', layout: false, locals: { loader: loader }
    rescue ArgumentError => e
      Rails.logger.error(e)
      render partial: 'form', layout: false, locals: { success: false, error: e.message }
    rescue StandardError => e
      Rails.logger.error(e)
      render partial: 'form', layout: false, locals: { success: false, error: 'An error occourred while uploading the data tables' }
    end

    def do_import
      @last_import = DataTable::Upload.where(successful: true).order(created_at: :asc).last
      load_tables
      render partial: 'form', layout: false, locals: { success: true, error: '' }
    rescue ArgumentError => e
      Rails.logger.error(e)
      render partial: 'form', layout: false, locals: { success: false, error: e.message }
    rescue StandardError => e
      Rails.logger.error(e)
      render partial: 'form', layout: false, locals: { success: false, error: e.message[0, 1000] }
    end

    def abort_import
      loader = DataTable::Upload.find(params['loader_id'])
      loader.destroy

      render partial: 'form', layout: false, locals: { success: false, error: 'The upload has been cancelled by the user' }
    end

  private

    def check_input_file
      raise(ArgumentError, 'Please upload a file') if params['file-upload'].blank?
      raise(ArgumentError, 'Wrong format. Please upload an Excel spreadsheet') unless DataTable.check_content_type(params['file-upload'])

      nil
    end

    def load_tables
      loader = DataTable::Upload.find(params['loader_id'])
      loader.process

      loader.update(successful: true)

      @last_import = DataTable::Upload.where(successful: true).order(created_at: :asc).last
    end
  end
end
