# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    name        { Faker::Lorem.unique.sentence(2) }
    description { Faker::Lorem.sentence(15) }

    after(:create, &:save)

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

    trait :with_subcategories_concepts_and_data_elements do
      after(:create) do |category|
        create(:category, :with_concepts_and_data_elements, parent: category)
      end
    end

    trait :with_concepts do
      after(:create) do |category|
        create(:concept, category: category)
      end
    end

    trait :with_concepts_and_data_elements do
      after(:create) do |category|
        create(:concept, :with_data_elements, category: category)
      end
    end
  end
end
