# frozen_string_literal: true

module Admin
  class ImportDatasetsController < Admin::ApplicationController
    layout 'admin/wide'

    include BreadcrumbBuilder

    def import
      trim_data_table_uploads(count: 10)

      custom_breadcrumbs_for(admin: true,
                             steps: [{ name: 'Manage dataset import and export', path: admin_uploads_path }],
                             leaf: 'Import datasets')

      render :import_start, locals: { success: nil, error: '' }
    end

    def preprocess
      back_breadcrumbs path: import_admin_import_datasets_path

      check_input_file
      loader = DataTable::Upload.create(admin_user: current_admin_user,
                                        file_name: params['file-upload'].original_filename,
                                        data_table: params['file-upload'])
      loader.data_table.attach(params['file-upload'])
      loader.preprocess

      if loader.data_table_tabs.recognised.any?
        redirect_to url_for(action: :recognised, id: loader.id)
      elsif loader.data_table_tabs.any?
        redirect_to url_for(action: :unrecognised, id: loader.id)
      else
        redirect_to url_for(action: :summary, id: loader.id)
      end
    rescue ArgumentError => e
      Rails.logger.error(e)
      @title = t('admin.data_tables.import.errors.generic')
      @description = e.message
      render :import_failure, locals: { tabs: [], loader: loader }
    rescue StandardError => e
      Rails.logger.error(e)
      @title = t('admin.data_tables.import.errors.generic')
      render :import_failure, locals: { tabs: [], loader: loader }
    end

    def recognised
      back_breadcrumbs path: import_admin_import_datasets_path

      loader = DataTable::Upload.find(params['id'])

      render :recognised, locals: { loader: loader }
    rescue ArgumentError => e
      Rails.logger.error(e)
      render :import_start, locals: { success: false, error: e.message }
    end

    def preprocess_recognised
      back_breadcrumbs path: import_admin_import_datasets_path

      loader = DataTable::Upload.find(params['id'])
      type = params.permit(:submit).dig(:submit)

      if type == 'cancel'
        redirect_to url_for(action: :abort_import, id: loader.id)
      else
        loader.data_table_tabs.recognised.update_all(selected: false)
        loader.data_table_tabs.recognised.where(id: params[:data_tabs]).update_all(selected: true)

        if type == 'unrecognised'
          redirect_to url_for(action: :unrecognised, id: loader.id)
        elsif type == 'summary'
          redirect_to url_for(action: :summary, id: loader.id)
        else
          render :recognised, locals: { loader: loader }
        end
      end
    rescue ArgumentError => e
      Rails.logger.error(e)
      render :recognised, locals: { success: false, error: e.message }
    end

    def unrecognised
      loader = DataTable::Upload.find(params['id'])
      back_breadcrumbs path: recognised_admin_import_datasets_path(id: loader.id)

      datasets = Dataset.where.not(id: loader.data_table_tabs.recognised.selected.pluck(:dataset_id))
      alias_fields = Dataset.pluck(:headers_regex).uniq.map { |el| (el || '').gsub('.?', ' ') }

      render :unrecognised, locals: { loader: loader, datasets: datasets, alias_fields: alias_fields }
    end

    def preprocess_unrecognised
      loader = DataTable::Upload.find(params['id'])
      back_breadcrumbs path: recognised_admin_import_datasets_path(id: loader.id)

      if params.permit(:submit).dig(:submit) == 'cancel'
        redirect_to url_for(action: :abort_import, id: loader.id)
      else
        loader.preprocess_unrecognised(params.dig(:data_tab))

        redirect_to url_for(action: :summary, id: loader.id)
      end
    rescue ArgumentError => e
      Rails.logger.error(e)
      render :unrecognised, locals: { success: false, error: e.message }
    end

    def summary
      loader = DataTable::Upload.find(params['id'])
      back_breadcrumbs path: unrecognised_admin_import_datasets_path(id: loader.id)

      if loader.data_table_tabs.selected.any?
        render :summary, locals: { loader: loader }
      else
        @title = t('admin.data_tables.import.errors.none_selected')
        flash[:error] = t('admin.data_tables.import.errors.none_selected')
        render :import_failure, locals: { tabs: [], loader: loader }
      end
    end

    def do_import
      loader = DataTable::Upload.find(params['id'])

      if params[:proceed] == 'yes' && params['Continue'] == 'Continue'
        loader.process

        flash[:notice] = t('admin.data_tables.import.success.title')
        render :import_success, locals: { loader: loader }
      else
        redirect_to url_for(action: :abort_import, id: loader.id)
      end
    rescue ArgumentError => e
      Rails.logger.error(e)
      @title = t('admin.data_tables.import.errors.generic')
      flash[:error] = t('admin.data_tables.import.errors.generic')
      render :import_failure, locals: { tabs: [], loader: loader }
    rescue StandardError => e
      Rails.logger.error(e)
      @title = t('admin.data_tables.import.errors.generic')
      flash[:error] = t('admin.data_tables.import.errors.generic')
      render :import_failure, locals: { tabs: [], loader: loader }
    end

    def abort_import
      loader = DataTable::Upload.find_by(id: params['id'])

      if loader.present?
        @title = t('admin.data_tables.import.cancelled.title')
        @description = t('admin.data_tables.import.cancelled.description')
        tabs = loader.data_table_tabs.pluck(:tab_name)
        loader&.destroy

        flash[:error] = t('admin.data_tables.import.errors.refused')
        render :import_failure, locals: { tabs: tabs }
      else
        redirect_to :import_admin_import_datasets
      end
    end
  end
end
