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

  it 'Will preprocess under 300ms' do
    expect { loader.preprocess }
      .to perform_under(300).ms.sample(10)
  end

  it 'Will process under 225ms' do
    loader.preprocess
    expect { loader.process }
      .to perform_under(225).ms.sample(10)
  end

  it 'Will preprocess the data table items' do
    expect { loader.preprocess }
      .to change(DataTable::Upload, :count).by(1)
      .and change(DataTable::Tab, :count).by(23)
      .and change(DataTable::Row, :count).by(274)
  end

  it 'Will process the data elements' do
    loader.preprocess
    expect { loader.process }
      .to change(DataElement, :count).by(274)
  end

  it 'Will know which new elements will be created' do
    loader.preprocess
    loader.process
    add_loader.preprocess
    expect(add_loader.new_rows.count).to eq(3)
  end

  it 'Will get new elements below 1ms' do
    loader.preprocess
    loader.process
    add_loader.preprocess
    expect { add_loader.new_rows }
      .to perform_under(1).ms.sample(10)
  end

  it 'Will know which elements will be deleted' do
    loader.preprocess
    loader.process
    del_loader.preprocess
    expect(del_loader.del_rows.count).to eq(3)
  end

  it 'Will get deleted elements below 1ms' do
    loader.preprocess
    loader.process
    del_loader.preprocess
    expect { del_loader.del_rows }
      .to perform_under(1).ms.sample(10)
  end
end
