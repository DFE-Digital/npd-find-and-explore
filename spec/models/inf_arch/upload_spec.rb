# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InfArch::Upload, type: :model do
  let(:admin_user) { create :admin_user }
  let(:table_path) { 'spec/fixtures/files/categories_table.xlsx' }
  let(:loader) do
    InfArch::Upload.new(admin_user: admin_user,
                        file_name: 'categories_table.xlsx',
                        data_table: table_path)
  end
  let(:reduced_table_path) { 'spec/fixtures/files/reduced_categories_table.xlsx' }
  let(:reduced_loader) do
    InfArch::Upload.new(admin_user: admin_user,
                        file_name: 'reduced_categories_table.xlsx',
                        data_table: reduced_table_path)
  end
  let(:reduced_no_headers_table_path) { 'spec/fixtures/files/reduced_categories_table_no_headers.xlsx' }
  let(:reduced_no_headers_loader) do
    InfArch::Upload.new(admin_user: admin_user,
                        file_name: 'reduced_categories_table_no_headers.xlsx',
                        data_table: reduced_no_headers_table_path)
  end
  let(:reduced_missing_tab_table_path) { 'spec/fixtures/files/reduced_categories_table_missing_tab.xlsx' }
  let(:reduced_missing_tab_loader) do
    InfArch::Upload.new(admin_user: admin_user,
                        file_name: 'reduced_categories_table_missing_tab.xlsx',
                        data_table: reduced_missing_tab_table_path)
  end
  let(:reduced_missing_header_table_path) { 'spec/fixtures/files/reduced_categories_table_missing_header.xlsx' }
  let(:reduced_missing_header_loader) do
    InfArch::Upload.new(admin_user: admin_user,
                        file_name: 'reduced_categories_table_missing_header.xlsx',
                        data_table: reduced_missing_header_table_path)
  end
  let(:de_table_path) { 'spec/fixtures/files/reduced_table.xlsx' }
  let(:de_loader) do
    DataTable::Upload.new(admin_user: admin_user,
                          file_name: 'reduced_table.xlsx',
                          data_table: de_table_path)
  end

  before do
    DataElement.destroy_all
    Concept.destroy_all
    Category.destroy_all
    Rails.configuration.datasets.each do |dataset|
      Dataset.find_or_create_by!(tab_name: dataset['tab_name'],
                                 name: dataset['name'],
                                 description: dataset['description'],
                                 tab_regex: dataset['tab_regex'],
                                 headers_regex: dataset['headers_regex'],
                                 first_row_regex: dataset['first_row_regex'])
    end
  end

  it 'Will preprocess under 175ms' do
    expect { reduced_loader.preprocess }
      .to perform_under(175).ms.sample(10)
  end

  it 'Will preprocess the infrastructure architecture items' do
    expect { reduced_loader.preprocess }
      .to change(InfArch::Upload, :count)
      .by(1)
      .and change(InfArch::Tab, :count)
      .by(4)
  end

  it 'will return errors if a tab is missing the headers' do
    reduced_no_headers_loader.preprocess
    expect(reduced_no_headers_loader.upload_errors)
      .to eq(["Can't find a header row for tab 'IA_Demographics'. " \
              "The first cell of a header row should read 'Category (L0)', " \
              'are you sure the header row is present and the headers are spelt correctly?'])
  end

  it 'will return a warning if a tab is missing' do
    reduced_missing_tab_loader.preprocess
    expect(reduced_missing_tab_loader.upload_errors)
      .to eq(["Can't find any suitable tab in the worksheet. " \
              "A suitable tab should start with the prefix 'IA_'. " \
              'If you proceed, all categories and concepts will be removed from the system.'])
  end

  it 'will return a warning if a header has missing columns' do
    reduced_missing_header_loader.preprocess
    expect(reduced_missing_header_loader.upload_errors)
      .to eq(["Can't find a column with header 'Category L3 Description' for tab 'IA_Demographics'"])
  end

  it 'Will process within 2000ms' do
    reduced_loader.preprocess
    expect { reduced_loader.process }
      .to perform_under(2000).ms.sample(10)
  end

  it 'Will process the categories and concepts' do
    reduced_loader.preprocess
    expect { reduced_loader.process }
      .to change(Category, :count)
      .by(69)
      .and change(Concept, :count)
      .by(347)
  end

  it 'Will assign a real concept to data elements' do
    de_loader.preprocess
    de_loader.process

    data_element = DataElement.find_by(npd_alias: 'KS4_ACTYRGRP')
    no_concept = Concept.find_by(name: 'No Concept')
    expect(no_concept.data_elements.count).to eq(274)
    expect(data_element.concept).to eq(no_concept)

    loader.preprocess
    loader.process
    new_concept = Concept.find_by(name: 'Actual year group')

    expect(no_concept.data_elements.count).to eq(57) # fix when the new IA tables are done
    expect(data_element.reload.concept).to eq(new_concept)
  end
end
