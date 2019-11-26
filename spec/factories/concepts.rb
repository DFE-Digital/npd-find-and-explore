# frozen_string_literal: true

FactoryBot.define do
  factory :concept do
    before(:create) do |concept, _evaluator|
      concept.name = Faker::Lorem.unique.sentence(2)
      concept.description = Faker::Lorem.sentence(15)
    end

    category

    trait :with_data_elements do
      after(:create) do |concept|
        create_list(:data_element, 3, concept: concept)
      end
    end
  end
end
