# frozen_string_literal: true

FactoryBot.define do
  factory :data_element do
    sequence(:npd_alias)             { |n| "NPD_Alias[#{n}]" }
    sequence(:source_table_name)     { %w[KS2_Exam KS2_Pupil KS3_Candidate KS3_Indicators KS3_Result KS4_Exam KS4_Pupil KS5_Exam KS5_Student].sample }
    sequence(:source_attribute_name) { |n| "#{Faker::Creature::Animal.name.strip}#{n}" }
    description_en                   { Faker::Lorem.sentence(3, false, 3) }
    source_old_attribute_name        { [Faker::Creature::Animal.name.strip] }
    identifiability                  { Random.rand(5) }
    sensitivity                      { %w[A B C D E].sample }
    academic_year_collected_from     { [2010, 2011, 2012].sample }
    academic_year_collected_to       { [2014, 2015, 2016, nil].sample }
    collection_terms                 { [%w[AUT SUM SPR].sample] }
    values                           { '0/1' }
    data_type                        { %w[Continuous Categorical Dichotomous Text].sample }
    educational_phase                { %w[EY PRI SEC P-16].sample }
  end
end
