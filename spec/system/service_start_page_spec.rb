# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Service start page', type: :system do
  it 'Has a link to the category tree view' do
    visit '/'
    find('span.js-step-title', text: 'Find and explore data in the NPD').click
    expect(page).to have_text('Find variables and metadata')
  end

  it 'Links the user to the top-level category tree view' do
    visit '/'
    find('span.js-step-title', text: 'Find and explore data in the NPD').click
    click_on('Find variables and metadata')
    expect(page).to have_current_path(categories_path)
    expect(page).to have_text('Categories')
  end

  it 'Has three mailto links to the data sharing team' do
    visit '/'
    expect(page).to have_link('data.sharing@education.gov.uk',
                              href: 'mailto:data.sharing@education.gov.uk',
                              count: 3,
                              visible: :all)
  end

  it 'Has a mailto link to the research support team' do
    visit '/'
    expect(page).to have_link('research.support@ons.gov.uk',
                              href: 'mailto:research.support@ons.gov.uk',
                              count: 1,
                              visible: :all)
  end

  it 'Links out to supporting resources' do
    visit '/'
    expect(page).to have_link('External shares',
                              href: 'https://www.gov.uk/government/publications/dfe-external-data-shares',
                              visible: :all)
    expect(page).to have_link('Data protection: how we share pupil and workforce data',
                              href: 'https://www.gov.uk/guidance/data-protection-how-we-collect-and-share-research-data',
                              visible: :all)
    expect(page).to have_link('Data collection and censuses for schools',
                              href: 'https://www.gov.uk/education/data-collection-and-censuses-for-schools',
                              visible: :all)

    expect(page).to have_link('Get a basic DBS check',
                              href: 'https://www.gov.uk/request-copy-criminal-record',
                              visible: :all)
    expect(page).to have_link('Register as an accredited researcher with the ONS',
                              href: 'https://www.ons.gov.uk/aboutus/whatwedo/statistics/requestingstatistics/approvedresearcherscheme',
                              visible: :all)
    expect(page).to have_link('Apply for access to the ONS Secure Research Service',
                              href: 'https://www.ons.gov.uk/aboutus/whatwedo/paidservices/virtualmicrodatalaboratoryvml',
                              visible: :all)

    expect(page).to have_link('Department for Education',
                              href: 'https://www.gov.uk/government/organisations/department-for-education#content',
                              visible: :all)
    expect(page).to have_link('ONS Secure Research Service',
                              href: 'https://www.ons.gov.uk/aboutus/whatwedo/paidservices/virtualmicrodatalaboratoryvml',
                              visible: :all)
  end
end
