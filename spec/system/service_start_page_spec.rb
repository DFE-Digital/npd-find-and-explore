# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Service start page', type: :system do
  it 'View the service start page' do
    visit '/'
    expect(page).to have_text('Find and explore data in the National Pupil Database')
    expect(page).to have_link('Start now')
  end
end
