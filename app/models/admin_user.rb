# frozen_string_literal: true

class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :lockable, :timeoutable

  has_many :data_table_uploads,
           class_name: 'DataTable::Uploads', inverse_of: :admin_user, dependent: :nullify
  has_many :inf_arch_uploads,
           class_name: 'InfArch::Uploads', inverse_of: :admin_user, dependent: :nullify

  validate :password_complexity

  def password_complexity
    return if password.blank?
    return if password.length >= 8 &&
      password =~ /[A-Z]+/ && password =~ /[a-z]+/ && password =~ /\d+/ &&
      password =~ /\W+/

    errors.add :password, 'is too simple. It should be minimum 8 characters
    and include at least 1 uppercase letter, 1 lowercase letter, 1 number and
    1 special character'
  end

  def update_unique_session_id!(unique_session_id)
    self.update_attribute(:unique_session_id, unique_session_id)
  end

protected

  def extract_ip_from(request)
    request.headers['X-Forwarded-For']&.split(':')&.first || request.remote_ip
  end
end
