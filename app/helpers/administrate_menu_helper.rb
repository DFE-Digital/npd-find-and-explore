# frozen_string_literal: true

module AdministrateMenuHelper
  include Administrate::ApplicationHelper

  def links(params)
    return '' if current_admin_user.blank?

    namespace_value = defined?(namespace) ? namespace : 'admin'

    links = Administrate::Namespace.new(namespace_value).resources.map do |resource|
      links = [link_to(
        display_resource_name(resource),
        [namespace_value, resource_index_route_key(resource)],
        class: ['navigation__link', "navigation__link--#{resource_state(resource, params)}"]
      )]
      links.push secondary_links(resource.name, params)
    end
    links.flatten.join.html_safe # rubocop:disable Rails/OutputSafety
  end

private

  SECONDARY_LINKS = {
    categories: [
      {
        name: 'Sort Categories',
        url_params: %i[tree admin categories],
        active: :tree
      },
      {
        name: 'Import Categories and Concepts',
        url_params: %i[import admin categories],
        active: :import
      }
    ],
    data_elements: [
      {
        name: 'Import Data Elements',
        url_params: %i[import admin data_elements],
        active: :import
      }
    ]
  }.freeze

  def secondary_links(resource, params)
    SECONDARY_LINKS[resource]&.map do |link|
      link_to(
        link[:name],
        link[:url_params],
        class: "navigation__link navigation__link--secondary navigation__link--#{active(link[:active], params)}"
      )
    end
  end

  def active(action, params)
    params[:action].to_s == action.to_s ? :active : :inactive
  end

  def resource_state(resource, params)
    return nav_link_state(resource) if defined?(nav_link_state)

    params[:controller] == resource.to_s ? :active : :inactive
  end
end
