# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InfArch::Tab, type: :model do
  let(:workbook_path) { 'spec/fixtures/files/categories_table.xlsx' }
  let(:workbook) { Roo::Spreadsheet.open(workbook_path) }
  let(:tab) { InfArch::Tab.create(workbook: workbook, tab_name: 'IA_Demographics') }
  let(:demographics) { tab.tree.dig(0) }
  let(:age) { demographics.dig('subcat', 0) }
  let(:family) { demographics.dig('subcat', 3) }
  let(:school_reg_det) { demographics.dig('subcat', 8) }
  let(:time_spent_in_ed) { school_reg_det.dig('subcat', 1) }
  let(:actual_hours_in_ed) { time_spent_in_ed.dig('subcat', 0) }
  let(:siblings) { family.dig('subcat', 0) }
  let(:expected_subcategories) do
    ['Age', 'Gender', 'Ethnicity', 'Family', 'Socio-economic status',
     'Location and mobility', 'Language', 'Special educational needs',
     'School registration details', 'Pupil name', 'Pupil contact details',
     'Pupil reference numbers', 'Specific pupil populations']
  end
  let(:expected_age_concepts) do
    ['Age at start of academic year', 'Month part of age at start of academic year',
     'Date of birth', 'Month of birth', 'Year of birth', 'Age', 'Exam DOB',
     'PLASC DOB', 'Expected DOB', 'Age of child at 31 March', 'Age of child at 31 August',
     'Source of DOB']
  end
  let(:expected_family_subcategories) do
    ['Siblings', 'Sibling birth order']
  end
  let(:expected_siblings_concepts) do
    ['Sibling group identifier (based on address)',
     'Sibling group identifier (based on address and surname)',
     'Number of siblings (based on address)',
     'Number of siblings (based on address and surname)']
  end
  let(:expected_time_spent_in_ed_subcategories) do
    ['Actual hours in education', 'Planned hours in education']
  end
  let(:expected_actual_hours_in_ed_subcategories) do
    ['Funded hours', 'Unit Contact Time', 'Hours at Setting']
  end

  it 'Will extract the tab_name from table' do
    expect(tab.tab_name).to eq('IA_Demographics')
  end

  it 'Will extract the sheet from table' do
    expect(tab.sheet.class.name).to eq('Roo::Excelx::Sheet')
  end

  it 'Will load the file and preprocess the Sheet object under 550ms' do
    expect {
      workbook = Roo::Spreadsheet.open(workbook_path)
      InfArch::Tab.new(workbook: workbook, tab_name: 'IA_Demographics')
    }.to perform_under(550).ms.sample(10)
  end

  it 'Will extract the demographics' do
    expect(demographics.dig('name')).to eq('Demographics')
  end

  it 'Will extract all demographics L1 subcategories' do
    expect(demographics.dig('subcat').map { |subcat| subcat.dig('name') })
      .to eq(expected_subcategories)
  end

  it 'Will extract no concepts for demographics' do
    expect(demographics.dig('concepts').count).to eq(0)
  end

  it 'Will extract no subcategories for age' do
    expect(age.dig('subcat').count).to eq(0)
  end

  it 'Will extract all age concepts' do
    expect(age.dig('concepts').map { |concept| concept.dig('name') })
      .to eq(expected_age_concepts)
  end

  it 'Will extract all L2 subcategories for family' do
    expect(family.dig('subcat').map { |subcat| subcat.dig('name') })
      .to eq(expected_family_subcategories)
  end

  it 'Will extract no concepts for family' do
    expect(family.dig('concepts').count).to eq(0)
  end

  it 'Will extract no subcategories for siblings' do
    expect(siblings.dig('subcat').count).to eq(0)
  end

  it 'Will extract all siblings concepts' do
    expect(siblings.dig('concepts').map { |concept| concept.dig('name') })
      .to eq(expected_siblings_concepts)
  end

  it 'Will extract all L3 subcategories for time spent in education' do
    expect(time_spent_in_ed.dig('subcat').map { |subcat| subcat.dig('name') })
      .to eq(expected_time_spent_in_ed_subcategories)
  end

  it 'Will extract no concepts for time spent in education' do
    expect(time_spent_in_ed.dig('concepts').count).to eq(0)
  end

  it 'Will extract no subcategories for actual hours in education' do
    expect(actual_hours_in_ed.dig('subcat').count).to eq(0)
  end

  it 'Will extract all concepts for actual hours in education' do
    expect(actual_hours_in_ed.dig('concepts').map { |concept| concept.dig('name') })
      .to eq(expected_actual_hours_in_ed_subcategories)
  end
end
