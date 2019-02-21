# frozen_string_literal: true

FactoryBot.define do
  factory :concept do
    name { Faker::Lorem.word }
    description { Faker::Lorem.sentence(15) }

    category
  end
end
