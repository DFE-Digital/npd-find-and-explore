# frozen_string_literal: true

module Admin
  class DataElementsController < Admin::ApplicationController
    layout :layout_by_resource

    def orphaned
      all_resources, datasets = extract_resources
      resources = order.apply(all_resources).page(params[:page]).per(records_per_page)
      page = Administrate::Page::Collection.new(dashboard, order: order)

      custom_breadcrumbs_for(admin: true,
                             steps: [{ name: 'Data Items', path: admin_data_elements_path }],
                             leaf: 'Orphaned Data Items')
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
    # Unfortunately there's a glitch: sometimes, when swapping prod and
    # staging, there's a glitch and the indexing gets lost.
    # This is a utility page, not listed in the menu, that will let you trigger
    # a re-index easily.
    # TODO: Find the reason behind the glitch, fix it and get rid of this
    # functionality completely.
    # ==========================================================================
    def reindex
      render :reindex, layout: layout_by_resource, locals: { success: nil, errors: [] }
    end

    def do_reindex
      DataElement.rebuild_pg_search_documents

      render :reindex,
             layout: layout_by_resource,
             locals: { success: true, errors: [] }
    rescue StandardError => e
      Rails.logger.error(e)
      render :reindex,
             layout: layout_by_resource,
             locals: { success: false, errors: ['There has been an error while reindexing the data items'] }
    end

  private

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
        'admin/application'
      else
        'admin/side_menu'
      end
    end
  end
end
