# frozen_string_literal: true

module Admin
  class CategoriesController < Admin::ApplicationController
    helper NestableHelper

    before_action :generate_breadcrumbs, only: %i[new create update]
    before_action :generate_back_breadcrumbs, only: %i[show edit]

    def index
      custom_breadcrumbs_for(admin: true,
                             leaf: 'Sort Categories and Concepts')

      @categories = Category.roots
    end

    def childless
      resources = Category.childless
      resources = order.apply(resources)
      resources = resources.page(params[:page]).per(records_per_page)
      page = Administrate::Page::Collection.new(dashboard, order: order)

      custom_breadcrumbs_for(admin: true,
                             leaf: t('admin.home.menu.categories.links.childless_categories'))

      render locals: {
        resources: resources,
        page: page
      }
    end

    def tree
      @categories = Category.roots.includes(concepts: :data_elements)

      render layout: false
    end

    def sort
      unless request.post? && params['sorted_changes'].present?
        render plain: "<strong>#{I18n.t('admin.actions.nestable.success')}</strong>"
        return
      end

      sorted_changes = params.permit(sorted_changes: {}).dig(:sorted_changes).to_h

      begin
        sorted_changes.each do |_id, change_log|
          parent = change_log[0]
          concepts, categories = change_log[1].split('|').partition { |node| /^concept-/ =~ node }

          if categories.any?
            update = -> { update_tree(categories, parent) }
            ActiveRecord::Base.transaction { update.call }
          end

          if concepts.any?
            Concept
              .where(id: concepts.map { |id| id.gsub(/^concept-/, '') })
              .update_all(category_id: parent)
          end
        end

        render plain: "<strong>#{I18n.t('admin.actions.nestable.success')}</strong>"
      rescue StandardError => e
        render plain: "<strong>#{I18n.t('admin.actions.nestable.error')}</strong>: #{e}", status: 500
      end
    end

    def import
      trim_inf_arch_uploads(count: 10)

      custom_breadcrumbs_for(admin: true,
                             leaf: t('admin.home.menu.import_export.links.import_ia_file'))

      render :import, layout: 'admin/application', locals: { success: nil, errors: [] }
    end

    def export
      custom_breadcrumbs_for(admin: true,
                             leaf: t('admin.home.menu.import_export.links.export_ia_file'))
    end

    def preprocess
      check_input_file

      loader = InfArch::Upload.create(admin_user: current_admin_user,
                                      file_name: params['file-upload'].original_filename,
                                      data_table: params['file-upload'])
      loader.data_table.attach(params['file-upload'])
      loader.preprocess

      render partial: 'preprocess', layout: false, locals: { loader: loader }
    rescue ArgumentError => e
      Rails.logger.error(e)
      render partial: 'import_form', layout: false, locals: { success: false, errors: [e.message] }
    rescue StandardError => e
      Rails.logger.error(e)
      render partial: 'import_form', layout: false, locals: { success: false, errors: ['An error occourred while uploading the information architecture file'] }
    end

    def do_import
      loader = InfArch::Upload.find(params['loader_id'])

      ActiveRecord::Base.transaction do
        Concept.where.not(name: 'No Concept').delete_all
        Category.where.not(name: 'No Category').delete_all
        loader.process
      end

      render partial: 'import_form', layout: false, locals: { success: true, errors: [] }
    rescue ArgumentError => e
      Rails.logger.error(e)
      render partial: 'import_form', layout: false, locals: { success: false, errors: [e.message] }
    rescue StandardError => e
      Rails.logger.error(e)
      render partial: 'import_form', layout: false, locals: { success: false, errors: ['There has been an error while processing your file'] }
    end

    def abort_import
      loader = InfArch::Upload.find(params['loader_id'])
      loader.destroy

      render partial: 'import_form', layout: false, locals: { success: false, errors: ['The upload has been cancelled by the user'] }
    end

    def download
      @categories = Category.roots.includes(concepts: :data_elements)
      filename = "F&E IA #{DateTime.now.strftime('%d %m %Y %H_%M')}.xlsx"
      cookies['download'] = { value: 'download-ia-table' }

      render xlsx: 'download.xlsx.axlsx', disposition: :inline, filename: filename
    end

    def records_per_page
      5
    end

  private

    def update_tree(tree_nodes, parent = nil)
      parent_node = parent.blank? ? nil : Category.find(parent)
      tree_nodes.each_with_index do |id, index|
        model = Category.find(id.to_s)
        model.parent = parent_node || nil
        model.position = index.to_i + 1
        model.save!
      end
    end

    def find_resources(search_term = nil)
      return Category.all.order(:name) if search_term.blank?

      Category.search(search_term)
              .includes(:concepts)
              .order(:name)
    end

    def generate_breadcrumbs
      custom_breadcrumbs_for(admin: true,
                             steps: [{ name: 'Sort Categories and Concepts', path: admin_categories_path }],
                             leaf: params[:id].present? ? requested_resource.name : params[:action].titleize)
    end
  end
end
