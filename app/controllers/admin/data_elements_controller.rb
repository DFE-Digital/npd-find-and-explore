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
      render :import, layout: 'admin/application', locals: { success: nil, error: '' }
    end

    def do_import
      DfEDataTables::DataElementsLoader.new(params['file-upload'])

      render partial: 'form', layout: false, locals: { success: true, error: '' }
    rescue ArgumentError => error
      Rails.logger.error(error)
      render partial: 'form', layout: false, locals: { success: false, error: 'Please upload an Excel spreadsheet' }
    rescue StandardError => error
      Rails.logger.error(error)
      render partial: 'form', layout: false, locals: { success: false, error: error }
    end
  end
end
