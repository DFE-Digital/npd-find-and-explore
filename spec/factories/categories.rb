# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "#{Faker::Creature::Animal.name.strip}#{n}" }
    description { Faker::Lorem.sentence(15) }

    trait :with_subcategories do
      after(:create) do |category|
        create(:category, parent: category)
      end
    end

    trait :with_subcategories_and_concepts do
      after(:create) do |category|
        create(:category, :with_concepts, parent: category)
      end
    end

    trait :with_concepts do
      after(:create) do |category|
        create(:concept, category: category)
      end
    end
  end
end
