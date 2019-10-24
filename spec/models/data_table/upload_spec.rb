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

  it 'Will preprocess under 250ms' do
    expect { loader.preprocess }
      .to perform_under(250).ms.sample(10)
  end

  it 'Will process under 230ms' do
    loader.preprocess
    expect { loader.process }
      .to perform_under(230).ms.sample(10)
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

  it 'Will add the appropriate data elements' do
    loader.preprocess
    loader.process
    add_loader.preprocess
    expect { add_loader.process }
      .to change(DataElement, :count).by(3)
  end

  it 'Will remove the appropriate data elements' do
    loader.preprocess
    loader.process
    del_loader.preprocess
    expect { del_loader.process }
      .to change(DataElement, :count).by(-3)
  end

  it 'Will know which new elements will be created' do
    loader.preprocess
    loader.process
    add_loader.preprocess
    expect(add_loader.new_rows.count).to eq(3)
  end

  it 'Will get a list of elements to be created below 1ms' do
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

  it 'Will get a list of elements to be deleted below 1ms' do
    loader.preprocess
    loader.process
    del_loader.preprocess
    expect { del_loader.del_rows }
      .to perform_under(1).ms.sample(10)
  end

  it 'will destroy itself below 6ms' do
    loader.preprocess
    expect { loader.destroy }
      .to perform_under(4).ms.sample(10)
  end
end
