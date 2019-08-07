# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Data Elements Import', type: :system do
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
    visit 'admin/data_elements/import'

    expect(page).not_to have_text('Last Upload Name')
  end

  it 'Will error if no file uploaded' do
    visit 'admin/data_elements/import'
    click_on('Upload')

    expect(page).to have_css('#file-upload:invalid')
  end

  it 'Will error if wrong file format uploaded' do
    visit 'admin/data_elements/import'
    attach_file('file-upload', Rails.root.join('spec', 'fixtures', 'files', 'k01.jpg'))
    click_on('Upload')

    expect(page).to have_text('Wrong format. Please upload an Excel spreadsheet')
  end

  it 'Will upload a file' do
    visit 'admin/data_elements/import'
    attach_file('file-upload', Rails.root.join('spec', 'fixtures', 'files', 'reduced_table.xlsx'))
    click_on('Upload')

    expect(page).to have_text('The file was processed and uploaded successfully', wait: 5)
    expect(page).to have_text('Last Upload Name')
  end
end
