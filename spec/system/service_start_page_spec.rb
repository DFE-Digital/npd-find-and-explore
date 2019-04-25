# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Service start page', type: :system do
  it 'Has a link to the category tree view' do
    visit '/'
    find('span.js-step-title', text: 'Find out what information is available in the NPD').click
    expect(page).to have_text('Find variables and metadata')
  end

  it 'Links the user to the top-level category tree view' do
    visit '/'
    find('span.js-step-title', text: 'Find out what information is available in the NPD').click
    click_on('Find variables and metadata')
    expect(page).to have_current_path(categories_path)
    expect(page).to have_text('Categories')
  end

  it 'Has a mailto link to the data sharing team' do
    visit '/'
    expect(page).to have_link('data.sharing@education.gov.uk', href: 'mailto:data.sharing@education.gov.uk')
  end

  xit 'Links out to supporting resources' do
    expect(page).to have_link('An introduction to the National Pupil Database', 'https://todo.example.com')
    expect(page).to have_link('Apply for National Pupil Database data', 'https://todo.example.com')
    expect(page).to have_link('Become an ONS accredited researcher', 'https://todo.example.com')
    expect(page).to have_link('Register to become an approved research centre', 'https://todo.example.com')

    expect(page).to have_link('Secure Research Service', 'https://todo.example.com')

    expect(page).to have_link('2018 version of the data table', 'https://todo.example.com')
  end
end
