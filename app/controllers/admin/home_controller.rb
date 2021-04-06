module Admin
  class HomeController < Admin::ApplicationController
    def index
      custom_breadcrumbs_for(admin: true)
    end
  end
end
