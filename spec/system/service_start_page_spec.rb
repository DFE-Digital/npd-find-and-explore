# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Service start page', type: :system do
  it 'View the service start page' do
    visit '/'
    expect(page).to have_text('Find and explore data in the National Pupil Database')
    expect(page).to have_link('Start now', href: categories_path)

    # TODO: add tests for external links
    #expect(page).to have_link('An introduction to the National Pupil Database', TODO)
    #expect(page).to have_link('Apply for National Pupil Database data', TODO)
    #expect(page).to have_link('Become an ONS accredited researcher', TODO)
    #expect(page).to have_link('Register to become an approved research centre', TODO)

    #expect(page).to have_link('Secure Research Service', TODO)

    #expect(page).to have_link('2018 version of the data table', TODO)
	expect(page).to have_link('data.sharing@education.gov.uk', href: 'mailto:data.sharing@education.gov.uk')
  end

  xit 'Has search' do
  end
end
