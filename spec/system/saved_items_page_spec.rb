# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Saved Items page', type: :system do
  it 'Will show the saved items page' do
    visit '/saved_items'
    expect(page).to have_text('My list', count: 1)
    expect(page).to have_text('You can export these data items into a CSV file.')
  end
end
