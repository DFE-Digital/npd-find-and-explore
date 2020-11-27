# frozen_string_literal: true

module Admin
  class DataElementsController < Admin::ApplicationController
    layout :layout_by_resource

    include BreadcrumbBuilder

    # ==========================================================================
    # Orphaned Data Elements
    # ==========================================================================

    def orphaned
      all_resources, datasets = extract_resources
      resources = order.apply(all_resources).page(params[:page]).per(records_per_page)
      page = Administrate::Page::Collection.new(dashboard, order: order)

      custom_breadcrumbs_for(admin: true,
                             steps: [{ name: 'Data Elements', path: admin_data_elements_path }],
                             leaf: 'Orphaned Data Elements')
      render locals: {
        datasets: datasets,
        resources: resources,
        page: page
      }
    end

    def assign_orphaned
      back_breadcrumbs

      if params[:data_elements].present? && params[:concept].present?
        concept = Concept.find(params[:concept])
        data_elements = DataElement.where(id: params[:data_elements])

        if params[:target] == 'preview'
          render locals: {
            concept: concept,
            data_elements: data_elements
          }
        elsif params[:target] == 'commit'
          if params[:proceed] == 'yes' && params['Continue'] == 'Continue'
            concept.data_elements << data_elements

            flash[:success] = t('admin.data_elements.orphaned.assign_to_concept.success')
          else
            flash[:error] = t('admin.data_elements.orphaned.errors.refused')
          end

          redirect_to orphaned_admin_data_elements_path, status: 303
        end
      else
        flash[:error] = t('admin.data_elements.orphaned.errors.missing_data')
        redirect_to orphaned_admin_data_elements_path
      end
    end

    # ==========================================================================
    # Import Data Elements
    # ==========================================================================

    def import
      @last_import = DataTable::Upload.where(successful: true).order(created_at: :asc).last
      render :import, layout: 'admin/application', locals: { success: nil, error: '' }
    end

    def preprocess
      @last_import = DataTable::Upload.where(successful: true).order(created_at: :asc).last
      check_input_file
      loader = DataTable::Upload.create(admin_user: current_admin_user,
                                        file_name: params['file-upload'].original_filename,
                                        data_table: params['file-upload'])
      loader.data_table.attach(params['file-upload'])
      loader.preprocess

      render partial: 'preprocess', layout: false, locals: { loader: loader }
    rescue ArgumentError => e
      Rails.logger.error(e)
      render partial: 'import_form', layout: false, locals: { success: false, error: e.message }
    rescue StandardError => e
      Rails.logger.error(e)
      render partial: 'import_form', layout: false, locals: { success: false, error: 'An error occourred while uploading the data tables' }
    end

    def do_import
      @last_import = DataTable::Upload.where(successful: true).order(created_at: :asc).last
      load_tables
      render partial: 'import_form', layout: false, locals: { success: true, error: '' }
    rescue ArgumentError => e
      Rails.logger.error(e)
      render partial: 'import_form', layout: false, locals: { success: false, error: e.message }
    rescue StandardError => e
      Rails.logger.error(e)
      render partial: 'import_form', layout: false, locals: { success: false, error: e.message[0, 1000] }
    end

    def abort_import
      loader = DataTable::Upload.find(params['loader_id'])
      loader.destroy

      render partial: 'import_form', layout: false, locals: { success: false, error: 'The upload has been cancelled by the user' }
    end

  private

    def load_tables
      loader = DataTable::Upload.find(params['loader_id'])
      loader.process

      loader.update(successful: true)

      @last_import = DataTable::Upload.where(successful: true).order(created_at: :asc).last
    end

    def extract_resources
      misplaced = DataElement.misplaced.includes(:datasets)
      [filter_elements(misplaced), misplaced.map(&:datasets).flatten.uniq]
    end

    def filter_elements(elements)
      dataset_id = params.permit(:filter_dataset).dig(:filter_dataset)
      if dataset_id.present?
        elements.where(datasets: { id: dataset_id })
      else
        elements
      end
    end

    def layout_by_resource
      if orphaned_actions?
        'admin/wide'
      else
        'admin/application'
      end
    end
  end
end
