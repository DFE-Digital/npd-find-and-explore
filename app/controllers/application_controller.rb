# frozen_string_literal: true

class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: Rails.application.credentials.dig(:basic_auth, :username) || '',
                               password: Rails.application.credentials.dig(:basic_auth, :password) || '',
                               unless: -> { Rails.env.test? }
  before_action :set_locale
  layout :layout_by_resource

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

private

  def layout_by_resource
    if devise_controller?
      'admin/application'
    else
      'application'
    end
  end
end
