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

  it 'Will preprocess under 600ms' do
    expect { loader.preprocess }
      .to perform_under(600).ms.sample(10)
  end

  it 'Will process under 300ms' do
    loader.preprocess
    expect { loader.process }
      .to perform_under(300).ms.sample(10)
  end

  it 'Will preprocess the data table items' do
    expect { loader.preprocess }
      .to change(DataTable::Upload, :count).by(1)
      .and change(DataTable::Tab, :count).by(23)
  end

  it 'Will process the data elements' do
    loader.preprocess
    expect { loader.process }
      .to change(DataElement, :count).by(274)
  end
end
