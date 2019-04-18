# frozen_string_literal: true

class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: Rails.application.credentials.dig(:basic_auth, :username) || '',
                               password: Rails.application.credentials.dig(:basic_auth, :password) || ''
  before_action :set_locale

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
end
