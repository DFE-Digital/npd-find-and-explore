# frozen_string_literal: true

FactoryBot.define do
  factory :admin_user do
    email { Faker::Internet.email }

    after(:build) do |admin_user|
      admin_user.update(password: 'P4ssw0rd!')
    end
  end
end
