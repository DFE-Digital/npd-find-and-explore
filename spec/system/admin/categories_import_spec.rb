# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Categories Import', type: :system do
  let(:password) { 'paSSw0rd!' }
  let(:admin_user) { AdminUser.create!(email: 'admin@test.com', password: password) }

  before do
    DataElement.destroy_all
    Concept.destroy_all
    Category.destroy_all

    admin_user

    visit '/admin'
    fill_in('admin_user_email', with: admin_user.email)
    fill_in('admin_user_password', with: password)
    click_on('Log in')
  end

  it 'Will not show the previously uploaded file if there is none' do
    visit 'admin/categories/import'

    expect(page).not_to have_text('Last Upload Name')
  end

  it 'Will error if no file uploaded' do
    visit 'admin/categories/import'
    click_on('Upload')

    expect(page).to have_css('#file-upload:invalid')
  end

  it 'Will error if wrong file format uploaded' do
    visit 'admin/categories/import'
    attach_file('file-upload', Rails.root.join('spec', 'fixtures', 'files', 'k01.jpg'))
    click_on('Upload')

    expect(page).to have_text('Wrong format. Please upload an Excel spreadsheet')
  end

  it 'Will error if a tab does not have the right headers' do
    visit 'admin/categories/import'
    attach_file('file-upload', Rails.root.join('spec', 'fixtures', 'files', 'reduced_categories_table_wrong_header.xlsx'))
    click_on('Upload')

    expect(page).to have_text("Can't find a column with header 'L0' or 'Standard Extract' for tab 'Demographics'")
  end

  it 'Will error if a tab is missing' do
    visit 'admin/categories/import'
    attach_file('file-upload', Rails.root.join('spec', 'fixtures', 'files', 'reduced_categories_table_missing_tab.xlsx'))
    click_on('Upload')

    expect(page).to have_text("Can't find a tab named 'Demographics'")
  end

  it 'Will upload a file' do
    visit 'admin/categories/import'
    attach_file('file-upload', Rails.root.join('spec', 'fixtures', 'files', 'reduced_categories_table.xlsx'))
    click_on('Upload')
    find_button('Confirm Upload', wait: 5)
    click_on('Confirm Upload')

    expect(page).to have_text('The file was processed and uploaded successfully', wait: 10)
  end

  it 'Will have a Go Back button' do
    visit 'admin/categories/import'
    attach_file('file-upload', Rails.root.join('spec', 'fixtures', 'files', 'reduced_categories_table.xlsx'))
    click_on('Upload')
    expect(page).to have_button('Go Back', wait: 5)
  end

  it 'Will abort the upload' do
    visit 'admin/categories/import'
    attach_file('file-upload', Rails.root.join('spec', 'fixtures', 'files', 'reduced_categories_table.xlsx'))
    click_on('Upload')
    find_button('Go Back', wait: 5)
    click_on('Go Back')

    expect(page).to have_text('The upload has been cancelled by the user', wait: 5)
  end
end
