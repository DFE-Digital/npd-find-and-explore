# frozen_string_literal: true

module AdministrateMenuHelper
  def links(params)
    links = Administrate::Namespace.new(namespace).resources.map do |resource|
      links = [link_to(
        display_resource_name(resource),
        [namespace, resource_index_route_key(resource)],
        class: ['navigation__link', "navigation__link--#{nav_link_state(resource)}"]
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
end
