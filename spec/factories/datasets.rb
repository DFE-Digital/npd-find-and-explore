# frozen_string_literal: true

FactoryBot.define do
  factory :dataset do
    tab_name    { %w[Year7 KS2 KS3 KS4 KS5 CLA].sample }
    name        { Faker::Lorem.word }
    description { Faker::Lorem.sentence(15) }

    after(:create, &:save)
  end
end
