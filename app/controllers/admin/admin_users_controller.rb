# frozen_string_literal: true

module Admin
  class AdminUsersController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # you can overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = AdminUser.
    #     page(params[:page]).
    #     per(10)
    # end

    def edit
      if requested_resource == current_admin_user
        redirect_to edit_admin_user_registration_path(current_admin_user)
      else
        super
      end
    end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   AdminUser.find_by!(slug: param)
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information
  end
end
