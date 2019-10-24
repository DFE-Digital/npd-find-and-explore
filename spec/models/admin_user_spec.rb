# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminUser, type: :model do
  it 'Should complain if the password is too simple' do
    admin_user = AdminUser.new(email: 'test@test.com', password: 'password')

    expect(admin_user.save).to be false
    expect(admin_user.errors.messages.dig(:password, 0))
      .to eq('is too simple. It should be minimum 8 characters and include at ' \
             'least 1 uppercase letter, 1 lowercase letter, 1 number and 1 ' \
             'special character')
  end

  it 'Will deactivate an admin user' do
    admin_user = create :admin_user
    admin_user.save!

    admin_user.deactivate!
    expect(admin_user.account_active?).to be false
  end

  it 'Will reactivate an admin user' do
    admin_user = create :admin_user
    admin_user.save!
    admin_user.deactivate!
    expect(admin_user.account_active?).to be false

    admin_user.reactivate!
    expect(admin_user.account_active?).to be true
  end
end
