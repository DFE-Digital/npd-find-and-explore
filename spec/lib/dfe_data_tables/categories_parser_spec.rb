# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DfEDataTables::CategoriesParser', type: :model do
  let(:table_path) { 'spec/fixtures/files/categories_table.xlsx' }
  let(:workbook) { Roo::Spreadsheet.open(table_path) }
  let(:parser) { DfEDataTables::CategoriesParser.new(workbook, 'Demographics') }
  let(:categories) { parser.categories }
  let(:demographics) { categories.dig(0) }
  let(:age) { demographics.dig(:subcat, 0) }
  let(:family) { demographics.dig(:subcat, 3) }
  let(:school_reg_det) { demographics.dig(:subcat, 8) }
  let(:time_spent_in_ed) { school_reg_det.dig(:subcat, 1) }
  let(:actual_hours_in_ed) { time_spent_in_ed.dig(:subcat, 0) }
  let(:siblings) { family.dig(:subcat, 0) }
  let(:expected_subcategories) do
    ['Age', 'Gender', 'Ethnicity', 'Family', 'Socio-economic Status', 'Geographic',
     'Language', 'Special Educational Needs', 'School Registration Details',
     'Pupil Name', 'Pupil Reference Numbers (PRNs)', 'Specific Pupil Populations']
  end
  let(:expected_age_concepts) do
    ['Age at start of academic year', 'Month Part of Age at Start of Academic Year',
     'Date of birth', 'Month of birth', 'Year of birth']
  end
  let(:expected_family_subcategories) do
    ['Siblings', 'Birth order']
  end
  let(:expected_siblings_concepts) do
    ['The pupil\'s sibling group identifier based on address only',
     'Number of siblings based on address',
     'Number of siblings in the pupil\'s sibling group based on address and surname',
     'The pupil\'s sibling group identifier based on address and surname']
  end
  let(:expected_time_spent_in_ed_subcategories) do
    ['Actual Hours in Education', 'Planned Hours in Education']
  end
  let(:expected_actual_hours_in_ed_subcategories) do
    ['Funded Hours', 'Unit Contact Time', 'Hours at Setting']
  end

  it 'Will extract the demographics' do
    expect(demographics.dig(:name)).to eq('Demographics')
  end

  it 'Will extract all demographics L1 subcategories' do
    expect(demographics.dig(:subcat).map { |subcat| subcat.dig(:name) })
      .to eq(expected_subcategories)
  end

  it 'Will extract no concepts for demographics' do
    expect(demographics.dig(:concepts).count).to eq(0)
  end

  it 'Will extract no subcategories for age' do
    expect(age.dig(:subcat).count).to eq(0)
  end

  it 'Will extract all age concepts' do
    expect(age.dig(:concepts).map { |concept| concept.dig(:name) })
      .to eq(expected_age_concepts)
  end

  it 'Will extract all L2 subcategories for family' do
    expect(family.dig(:subcat).map { |subcat| subcat.dig(:name) })
      .to eq(expected_family_subcategories)
  end

  it 'Will extract no concepts for family' do
    expect(family.dig(:concepts).count).to eq(0)
  end

  it 'Will extract no subcategories for siblings' do
    expect(siblings.dig(:subcat).count).to eq(0)
  end

  it 'Will extract all siblings concepts' do
    expect(siblings.dig(:concepts).map { |concept| concept.dig(:name) })
      .to eq(expected_siblings_concepts)
  end

  it 'Will extract all L3 subcategories for time spent in education' do
    expect(time_spent_in_ed.dig(:subcat).map { |subcat| subcat.dig(:name) })
      .to eq(expected_time_spent_in_ed_subcategories)
  end

  it 'Will extract no concepts for time spent in education' do
    expect(time_spent_in_ed.dig(:concepts).count).to eq(0)
  end

  it 'Will extract no subcategories for actual hours in education' do
    expect(actual_hours_in_ed.dig(:subcat).count).to eq(0)
  end

  it 'Will extract all concepts for actual hours in education' do
    expect(actual_hours_in_ed.dig(:concepts).map { |concept| concept.dig(:name) })
      .to eq(expected_actual_hours_in_ed_subcategories)
  end
end
