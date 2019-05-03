# frozen_string_literal: true

module Admin
  class CategoriesController < Admin::ApplicationController
    helper NestableHelper

    # To customize the behavior of this controller,
    # you can overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = Category.
    #     page(params[:page]).
    #     per(10)
    # end

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
  end
end
