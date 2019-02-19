require 'securerandom'

FactoryBot.define do
  factory :category do
    name { Faker::Creature::Animal.name }
    description  { Faker::Lorem.sentence(15) }

    trait :with_subcategories do
      after(:create) do |category|
        create(:category, parent: category)
      end
    end
  end
end