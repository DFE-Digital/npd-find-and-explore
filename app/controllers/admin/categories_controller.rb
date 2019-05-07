# frozen_string_literal: true

module Admin
  class CategoriesController < Admin::ApplicationController
    helper NestableHelper
    include BreadcrumbBuilder

    before_action :generate_breadcrumbs, only: %i[show edit]

    # To customize the behavior of this controller,
    # you can overwrite any of the RESTful actions. For example:
    #
    def index
      search_term = params[:search].to_s.strip
      resources = find_resources(search_term)
      resources = apply_resource_includes(resources)
      resources = order.apply(resources)
      resources = resources.page(params[:page]).per(records_per_page)
      page = Administrate::Page::Collection.new(dashboard, order: order)

      render locals: {
        resources: resources,
        search_term: search_term,
        page: page,
        show_search_bar: show_search_bar?,
      }
    end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   Category.find_by!(slug: param)
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information

    def tree
      @categories = Category.includes(:translations).arrange(order: :position)
    end

    def sort
      render plain: '' && return unless request.post? && params['tree_nodes'].present?

      begin
        update = -> { update_tree(params[:tree_nodes]) }

        PgSearch.disable_multisearch do
          ActiveRecord::Base.transaction { update.call }
        end
        PgSearch::Multisearch.rebuild(Category)

        message = "<strong>#{I18n.t('admin.actions.nestable.success')}!</strong>"
      rescue StandardError => e
        message = "<strong>#{I18n.t('admin.actions.nestable.error')}</strong>: #{e}"
      end

      render plain: message
    end

  private

    def update_tree(tree_nodes, parent_node = nil)
      tree_nodes.each do |key, value|
        model = Category.find(value['id'].to_s)
        model.parent = parent_node || nil
        model.position = key.to_i + 1
        model.save!
        update_tree(value['children'], model) if value.key?('children')
      end
    end

    def find_resources(search_term = nil)
      return Category.all if search_term.blank?

      Category.where(id: PgSearch.multisearch(search_term)
                                 .where(searchable_type: 'Category')
                                 .pluck(:searchable_id))
              .includes(:translations, concepts: :translations)
    end

    def generate_breadcrumbs
      admin_breadcrumbs_for(category_leaf: requested_resource)
    end
  end
end
