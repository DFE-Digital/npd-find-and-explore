# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Concepts Childless', type: :system do
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
  let(:concept) { create(:concept, :with_data_elements) }
  let(:empty_concept) { create(:concept) }

  it 'has no empty concepts' do
    concept
    visit '/admin/concepts/childless'

    expect(page).not_to have_css('[data-url]')
  end

  it 'will show an empty concept' do
    empty_concept
    visit '/admin/concepts/childless'

    expect(page).to have_css('[data-url]')
    expect(page).to have_text(empty_concept.name)
  end
end
