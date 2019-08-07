# frozen_string_literal: true

module Admin
  class ConceptsController < Admin::ApplicationController
    include BreadcrumbBuilder

    before_action :generate_breadcrumbs, only: %i[show edit]

    # To customize the behavior of this controller,
    # you can overwrite any of the RESTful actions. For example:
    #
    def index
      search_term = params[:search].to_s.strip
      resources = find_resources(search_term)
      resources = apply_resource_includes(resources)
      # TODO: From the next version of Administrate it may be necessary to
      # remove the above line and uncomment the following
      # resources = apply_collection_includes(resources)
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
    #   Concept.find_by!(slug: param)
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information

    def reindex
      render :reindex, layout: 'admin/application', locals: { success: nil, error: '' }
    end

    def do_reindex
      PgSearch::Multisearch.rebuild(Concept)

      render :reindex, layout: 'admin/application', locals: { success: true, error: '' }
    rescue StandardError => error
      Rails.logger.error(error)
      render :reindex, layout: 'admin/application', locals: { success: false, error: 'There has been an error while reindexing the concepts' }
    end

  private

    def find_resources(search_term = nil)
      return Concept.all if search_term.blank?

      Concept.where(id: PgSearch.multisearch(search_term)
                                .where(searchable_type: 'Concept')
                                .pluck(:searchable_id))
             .includes(:translations, category: :translations)
    end

    def generate_breadcrumbs
      admin_breadcrumbs_for(category_leaf: requested_resource.category, concept: requested_resource)
    end
  end
end
