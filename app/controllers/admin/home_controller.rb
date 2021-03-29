module Admin
  class HomeController < Admin::ApplicationController
    layout 'admin/application'

    def index
      custom_breadcrumbs_for(admin: true)
    end
  end
end
