# frozen_string_literal: true

module Admin
  class AdminUsersController < Admin::ApplicationController
    layout 'admin/application'
    before_action :generate_back_breadcrumbs, only: %i[show edit create update]
    before_action :generate_breadcrumbs, only: %i[index]
    before_action :set_minimum_password_length, only: %i[new edit create update]

    def edit
      if requested_resource == current_admin_user
        redirect_to edit_admin_user_registration_path(current_admin_user)
      else
        super
      end
    end

    def deactivate
      if requested_resource == current_admin_user
        flash[:error] = "Can't deactivate self!"
      else
        requested_resource.deactivate!
      end
      redirect_to action: :index
    end

    def reactivate
      if requested_resource == current_admin_user
        flash[:error] = "Can't reactivate self!"
      else
        requested_resource.reactivate!
      end
      redirect_to action: :index
    end

  private

    def generate_breadcrumbs
      custom_breadcrumbs_for(admin: true,
                             leaf: I18n.t('admin.home.menu.admin.links.users'))
    end

    def set_minimum_password_length
      @minimum_password_length = Devise.password_length&.min
    end
  end
end
