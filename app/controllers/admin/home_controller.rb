module Admin
  class HomeController < Admin::ApplicationController
    include BreadcrumbBuilder

    layout 'admin/application'

    def index
      custom_breadcrumbs_for(admin: true)
    end
  end
end
