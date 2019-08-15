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
      check_input_file

      unless loader.preprocess
        render partial: 'form', layout: false, locals: { success: false, error: loader.errors.join(', ') }
        return
      end

      loader.preprocess

      if loader.errors.any?
        render partial: 'form', layout: false, locals: { success: false, error: loader.errors.join(', ') }
        return
      end

      load_tables
      render partial: 'form', layout: false, locals: { success: true, error: '' }
    rescue ArgumentError => e
      Rails.logger.error(e)
      render partial: 'form', layout: false, locals: { success: false, error: error.message }
    rescue StandardError => e
      Rails.logger.error(e)
      @last_import = DfEDataTable.order(created_at: :asc).last

      render partial: 'form', layout: false, locals: { success: false, error: e.message[0, 1000] }
    end

  private

    def check_input_file
      @last_import = DfEDataTable.order(created_at: :asc).last

      raise(ArgumentError, 'Please upload a file') if params['file-upload'].blank?
      raise(ArgumentError, 'Wrong format. Please upload an Excel spreadsheet') unless DataTable.check_content_type(params['file-upload'])

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

      render partial: 'form', layout: false, locals: { success: true, error: '' }
    rescue StandardError => e
      Rails.logger.error(e)
      @last_import = DfEDataTable.order(created_at: :asc).last

      render partial: 'form', layout: false, locals: { success: false, error: 'There has been an error while processing your file' }
    end

  private

    def check_input_file
      @last_import = DfEDataTable.order(created_at: :asc).last

      raise(ArgumentError, 'Please upload a file') if params['file-upload'].blank?
      raise(ArgumentError, 'Wrong format. Please upload an Excel spreadsheet') unless DfEDataTables.check_content_type(params['file-upload'])

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
