# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_locale
  layout :layout_by_resource

private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def current_user
    current_admin_user
  end

  def can_administer?
    current_admin_user
  end

  def layout_by_resource
    if devise_controller?
      'admin/application'
    elsif /rapidfire/.match?(params[:controller])
      'admin/application'
    else
      'application'
    end
  end
end
