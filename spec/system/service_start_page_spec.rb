# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Service start page', type: :system do
  it 'Directs users to the category tree view' do
    visit '/'
    expect(page).to have_text('Find and explore data in the National Pupil Database')
    expect(page).to have_link('Start now', href: categories_path)
  end

  xit 'Links out to supporting resources' do
    expect(page).to have_link('An introduction to the National Pupil Database', 'https://todo.example.com')
    expect(page).to have_link('Apply for National Pupil Database data', 'https://todo.example.com')
    expect(page).to have_link('Become an ONS accredited researcher', 'https://todo.example.com')
    expect(page).to have_link('Register to become an approved research centre', 'https://todo.example.com')

    expect(page).to have_link('Secure Research Service', 'https://todo.example.com')

    expect(page).to have_link('2018 version of the data table', 'https://todo.example.com')
    expect(page).to have_link('data.sharing@education.gov.uk', href: 'mailto:data.sharing@education.gov.uk')
  end

  xit 'Has search' do
  end
end
