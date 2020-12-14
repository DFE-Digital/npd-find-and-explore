# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataTable::Upload, type: :model do
  let(:admin_user) { create :admin_user }
  let(:table_path) { 'spec/fixtures/files/reduced_table.xlsx' }
  let(:loader) do
    DataTable::Upload.new(admin_user: admin_user,
                          file_name: 'reduced_table.xlsx',
                          data_table: table_path)
  end
  let(:table_add_path) { 'spec/fixtures/files/reduced_table_add.xlsx' }
  let(:add_loader) do
    DataTable::Upload.new(admin_user: admin_user,
                          file_name: 'reduced_table_add.xlsx',
                          data_table: table_add_path)
  end
  let(:table_del_path) { 'spec/fixtures/files/reduced_table_del.xlsx' }
  let(:del_loader) do
    DataTable::Upload.new(admin_user: admin_user,
                          file_name: 'reduced_table_del.xlsx',
                          data_table: table_del_path)
  end

  before do
    Rails.configuration.datasets.each do |dataset|
      Dataset.find_or_create_by!(tab_name: dataset['tab_name'],
                                 name: dataset['name'],
                                 description: dataset['description'],
                                 tab_regex: dataset['tab_regex'],
                                 headers_regex: dataset['headers_regex'],
                                 first_row_regex: dataset['first_row_regex'])
    end
  end

  it 'Will preprocess under 275ms' do
    expect { loader.preprocess }
      .to perform_under(275).ms.sample(10)
  end

  it 'Will process under 300ms' do
    loader.preprocess
    expect { loader.process }
      .to perform_under(300).ms.sample(10)
  end

  it 'Will preprocess the data table items' do
    expect { loader.preprocess }
      .to change(DataTable::Upload, :count)
      .by(1)
      .and change(DataTable::Tab, :count)
      .by(48)
      .and change(DataTable::Row, :count)
      .by(279)
  end

  it 'Will recognise the datasets in the system' do
    loader.preprocess
    upload = DataTable::Upload.first
    expect(upload.data_table_tabs.count).to eq(48)
    expect(upload.data_table_tabs.recognised.count).to eq(23)
    expect(upload.data_table_tabs.unrecognised.count).to eq(25)
  end

  it 'Will process the data elements' do
    loader.preprocess
    loader.data_table_tabs.update_all(selected: true)
    expect { loader.process }
      .to change(DataElement, :count)
      .by(274)
  end

  it 'Will add the appropriate data elements' do
    loader.preprocess
    loader.data_table_tabs.update_all(selected: true)
    loader.process
    add_loader.preprocess
    add_loader.data_table_tabs.update_all(selected: true)
    expect { add_loader.process }
      .to change(DataElement, :count)
      .by(3)
  end

  it 'Will not remove data elements' do
    loader.preprocess
    loader.data_table_tabs.update_all(selected: true)
    loader.process
    del_loader.preprocess
    del_loader.data_table_tabs.update_all(selected: true)
    expect { del_loader.process }
      .not_to change(DataElement, :count)
  end

  it 'Will know which new elements will be created' do
    loader.preprocess
    loader.data_table_tabs.update_all(selected: true)
    loader.process
    add_loader.preprocess
    add_loader.data_table_tabs.update_all(selected: true)
    expect(add_loader.new_rows.count).to eq(3)
  end

  it 'Will get a list of elements to be created below 1ms' do
    loader.preprocess
    loader.data_table_tabs.update_all(selected: true)
    loader.process
    add_loader.preprocess
    add_loader.data_table_tabs.update_all(selected: true)
    expect { add_loader.new_rows }
      .to perform_under(1).ms.sample(10)
  end

  it 'Will know which elements will be deleted' do
    loader.preprocess
    loader.data_table_tabs.update_all(selected: true)
    loader.process
    del_loader.preprocess
    del_loader.data_table_tabs.update_all(selected: true)
    expect(del_loader.del_rows.count).to eq(3)
  end

  it 'Will get a list of elements to be deleted below 1ms' do
    loader.preprocess
    loader.data_table_tabs.update_all(selected: true)
    loader.process
    del_loader.preprocess
    del_loader.data_table_tabs.update_all(selected: true)
    expect { del_loader.del_rows }
      .to perform_under(1).ms.sample(10)
  end

  it 'will destroy itself below 6ms' do
    loader.preprocess
    loader.data_table_tabs.update_all(selected: true)
    expect { loader.destroy }
      .to perform_under(4).ms.sample(10)
  end

  context 'With a SLD Alias dataset' do
    before do
      Dataset.find_or_create_by!(tab_name: 'SLD-KS2_PT_05-06_to_15-16',
                                 name: 'SLD-KS2 PT 05-06 to 15-16',
                                 description: 'This is the Key Stage 2 school-level publication file.',
                                 tab_regex: '^SLD.?KS2.?PT.?\d{2}.?\d{2}.?to.?15.?16',
                                 headers_regex: 'SLD.?Alias',
                                 first_row_regex: '---')
    end

    it 'Will recognise the datasets in the system' do
      loader.preprocess
      upload = DataTable::Upload.first
      expect(upload.data_table_tabs.count).to eq(48)
      expect(upload.data_table_tabs.recognised.count).to eq(24)
      expect(upload.data_table_tabs.unrecognised.count).to eq(24)
    end

    it 'Will preprocess the data elements' do
      expect { loader.preprocess }
        .to change(DataTable::Row, :count)
        .by(284)
    end

    it 'Will process the data elements' do
      loader.preprocess
      loader.data_table_tabs.update_all(selected: true)
      expect { loader.process }
        .to change(DataElement, :count)
        .by(279)
    end
  end
end
