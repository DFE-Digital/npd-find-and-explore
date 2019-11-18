FactoryBot.define do
  factory :dataset do
    tab_name { %w[Year7 KS2 KS3 KS4 KS5 CLA].sample }
    tab_type { %w[DataTable::Year7 DataTable::Ks2 DataTable::Ks3 DataTable::Ks4
                  DataTable::Ks5 DataTable::Cla].sample }

    after(:build) do |dataset, _evaluator|
      dataset.name = Faker::Lorem.word
      dataset.description = Faker::Lorem.sentence(15)
    end
  end
end
