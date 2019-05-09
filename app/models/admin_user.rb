# frozen_string_literal: true

class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :lockable, :timeoutable

  has_many :dfe_data_tables, inverse_of: :admin_user, dependent: :nullify

protected

  def extract_ip_from(request)
    request.headers['X-Forwarded-For'] || request.remote_ip
  end
end
