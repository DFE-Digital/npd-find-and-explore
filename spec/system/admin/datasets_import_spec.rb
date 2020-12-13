# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Datasets Import', type: :system do
  let(:password) { 'paSSw0rd!' }
  let(:admin_user) { AdminUser.create!(email: 'admin@test.com', password: password) }

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

    admin_user

    visit '/admin'
    fill_in('admin_user_email', with: admin_user.email)
    fill_in('admin_user_password', with: password)
    click_on('Log in')
  end

  it 'Will error if no file uploaded' do
    visit 'admin/import_datasets/import'
    click_on('Continue')

    expect(page).to have_css('#file-upload:invalid')
  end

  it 'Will error if wrong file format uploaded' do
    visit 'admin/import_datasets/import'
    attach_file('file-upload', Rails.root.join('spec', 'fixtures', 'files', 'k01.jpg'))
    click_on('Continue')

    expect(page).to have_text('Wrong format. Please upload an Excel spreadsheet')
  end

  it 'Will upload recognised datasets from a file' do
    visit 'admin/import_datasets/import'
    attach_file('file-upload', Rails.root.join('spec', 'fixtures', 'files', 'reduced_table.xlsx'))
    click_on('Continue')

    find_button('Import recognised datasets only', wait: 5)
    find_all('input[name="data_tabs[]"]', visible: :all).each { |element| element.set(true) }
    click_on('Import recognised datasets only')

    find_button('Confirm', wait: 5)
    find('#proceed-yes', visible: :all).set(true)
    click_on('Confirm')

    expect(page).to have_text('Import has been successful', wait: 5)
  end

  xit 'Will upload unrecognised datasets from a file' do
    # write some test for the new scenario
  end

  it 'Will have a Cancel import button' do
    visit 'admin/import_datasets/import'
    attach_file('file-upload', Rails.root.join('spec', 'fixtures', 'files', 'reduced_table.xlsx'))
    click_on('Continue')
    expect(page).to have_button('Cancel import', wait: 5)
  end

  it 'Will abort the upload' do
    visit 'admin/import_datasets/import'
    attach_file('file-upload', Rails.root.join('spec', 'fixtures', 'files', 'reduced_table.xlsx'))
    click_on('Continue')
    find_button('Cancel import', wait: 5)
    click_on('Cancel import')

    expect(page)
      .to have_text('The following datasets have not been imported due to the import having been cancelled',
                    wait: 5)
    expect(page).to have_link('Continue to "Choose a file to upload"')
  end
end
