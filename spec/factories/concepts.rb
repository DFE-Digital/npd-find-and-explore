# frozen_string_literal: true

FactoryBot.define do
  factory :concept do
    name { Faker::Lorem.word }
    description { Faker::Lorem.sentence(15) }

    category

    trait :with_data_elements do
      after(:create) do |concept|
        create_list(:data_element, 3, concept: concept)
      end
    end
  end
end
