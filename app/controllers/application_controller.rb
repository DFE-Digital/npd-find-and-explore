# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?
  layout :layout_by_resource

private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def layout_by_resource
    if devise_controller?
      'admin/application'
    else
      'application'
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update) do |user_params|
      user_params.permit(:password, :password_confirmation, :current_password)
    end
  end
end
