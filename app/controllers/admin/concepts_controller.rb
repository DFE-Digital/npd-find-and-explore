# frozen_string_literal: true

module Admin
  class ConceptsController < Admin::ApplicationController
    layout :layout_by_resource

    include BreadcrumbBuilder

    before_action :generate_breadcrumbs, only: %i[new create show edit update]

    # To customize the behavior of this controller,
    # you can overwrite any of the RESTful actions. For example:
    #
    def index
      search_term = params[:search].to_s.strip
      resources = find_resources(search_term)
      resources = apply_collection_includes(resources)
      resources = order.apply(resources)
      resources = resources.page(params[:page]).per(records_per_page)
      page = Administrate::Page::Collection.new(dashboard, order: order)

      render locals: {
        resources: resources,
        search_term: search_term,
        page: page,
        show_search_bar: show_search_bar?
      }
    end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   Concept.find_by!(slug: param)
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information

    def childless
      resources = Concept.childless.includes(:category)
      resources = order.apply(resources)
      resources = resources.page(params[:page]).per(records_per_page)
      page = Administrate::Page::Collection.new(dashboard, order: order)

      render locals: {
        resources: resources,
        page: page
      }
    end

  private

    def layout_by_resource
      if %w[new create show edit update].include?(params[:action])
        'admin/application'
      else
        'admin/side_menu'
      end
    end

    def find_resources(search_term = nil)
      return Concept.all.order(:name) if search_term.blank?

      Concept.search(search_term)
             .includes(:category)
             .order(:name)
    end

    def generate_breadcrumbs
      custom_breadcrumbs_for(admin: true,
                             steps: [{ name: 'Sort Categories and Concepts', path: admin_categories_path }],
                             leaf: params[:id].present? ? requested_resource.name : params[:action].titleize)
    end
  end
end
