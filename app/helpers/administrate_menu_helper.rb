# frozen_string_literal: true

module AdministrateMenuHelper
  include Administrate::ApplicationHelper

  def links
    return '' if current_admin_user.blank?

    links = RESOURCES.map do |_label, resource|
      resource_links = [generate_link('primary', resource[:main])]
      resource[:secondary].each do |secondary|
        resource_links.push(generate_link('secondary', secondary))
      end
      resource_links
    end

    links.flatten.join.html_safe
  end

private

  RESOURCES = {
    categories: {
      main: {
        name: 'Categories',
        url_params: %i[admin categories],
        conditions: {
          controller: 'admin/categories',
          actions: %i[index show edit childless tree sort]
        }
      },
      secondary: [
        {
          parent: :categories,
          name: 'Childless Categories',
          url_params: %i[childless admin categories],
          conditions: {
            controller: 'admin/categories',
            action: :childless
          }
        },
        {
          name: 'Sort Categories',
          url_params: %i[tree admin categories],
          conditions: {
            controller: 'admin/categories',
            action: :tree
          }
        },
        {
          name: 'Reindex Categories for search',
          url_params: %i[reindex admin categories],
          conditions: {
            controller: 'admin/categories',
            action: :reindex
          }
        }
      ]
    },
    concepts: {
      main: {
        name: 'Categories',
        url_params: %i[admin categories],
        conditions: {
          controller: 'admin/categories',
          actions: %i[index show edit childless tree sort]
        }
      },
      secondary: [
        {
          name: 'Childless Concepts',
          url_params: %i[childless admin concepts],
          conditions: {
            controller: 'admin/concepts',
            action: :childless
          }
        },
        {
          name: 'Reindex Concepts for search',
          url_params: %i[reindex admin concepts],
          conditions: {
            controller: 'admin/concepts',
            action: :reindex
          }
        }
      ]
    },
    data_elements: {
      main: {
        name: 'Categories',
        url_params: %i[admin categories],
        conditions: {
          controller: 'admin/categories',
          actions: %i[index show edit childless tree sort]
        }
      },
      secondary: [
        {
          name: 'Orphaned Data Elements',
          url_params: %i[orphaned admin data_elements],
          conditions: {
            controller: 'admin/data_elements',
            action: :orphaned
          }
        }
      ]
    },
    files: {
      main: {
        name: 'Uploads and Downloads'
      },
      secondary: [
        {
          name: 'Manage Uploads',
          url_params: %i[admin uploads],
          conditions: {
            controller: 'admin/uploads',
            action: :index
          }
        },
        {
          name: 'Import Data Elements',
          url_params: %i[import admin data_elements],
          conditions: {
            controller: 'admin/data_elements',
            action: :import
          }
        },
        {
          name: 'Import Categories and Concepts',
          url_params: %i[import admin categories],
          conditions: {
            controller: 'admin/categories',
            action: :import
          }
        },
        {
          name: 'Export Categories and Concepts',
          url_params: %i[export admin categories],
          conditions: {
            controller: 'admin/categories',
            action: :export
          }
        }
      ]
    },
    admin_users: {
      main: {
        name: 'Admin Users',
        url_params: %i[admin admin_users],
        conditions: {
          controller: 'admin/admin_users'
        }
      },
      secondary: []
    }
  }.freeze

  def generate_link(level, params)
    link_to(
      params[:name],
      params[:url_params] || '#',
      class: "navigation__link navigation__link--#{level} navigation__link--#{active(params[:conditions], params)}"
    )
  end

  def active(conditions, params)
    return :inactive unless conditions && params

    return :active if params[:controller].to_s == conditions[:controller].to_s &&
      params[:action].to_s == conditions[:action].to_s

    :inactive
  end
end
