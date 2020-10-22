# frozen_string_literal: true

module AdministrateMenuHelper
  include Administrate::ApplicationHelper

  def menu_links
    return '' if current_admin_user.blank?

    links = Rails.configuration.administrate_menu.map do |_label, resource|
      resource_links = [generate_link('primary', resource['main'])]

      resource['secondary']&.each do |secondary|
        resource_links.push(generate_link('secondary', secondary))
      end
      resource_links
    end

    links.flatten.join.html_safe
  end

private

  def generate_link(level, link_params)
    link_to(
      link_params['name'],
      main_app.url_for(link_params['url_params'] || '#'),
      class: "navigation__link navigation__link--#{level} navigation__link--#{active(link_params['conditions'])}"
    )
  end

  def active(conditions)
    return :inactive unless conditions

    active = conditions.reduce(false) do |memo, condition|
      memo ||
        (params[:controller].to_s == condition['controller'].to_s &&
         condition['actions']&.include?(params[:action].to_s))
    end
    return :active if active

    :inactive
  end
end
