# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Categories Childless', type: :system do
  let(:password) { 'paSSw0rd!' }
  let(:admin_user) { AdminUser.create!(email: 'admin@test.com', password: password) }

  before do
    DataElement.destroy_all
    Concept.destroy_all
    Category.destroy_all

    admin_user
    create(:category, :with_subcategories_concepts_and_data_elements)

    visit '/admin'
    fill_in('admin_user_email', with: admin_user.email)
    fill_in('admin_user_password', with: password)
    click_on('Log in')
  end

  it 'has no empty categories' do
    visit '/admin/categories/childless'

    expect(page).not_to have_css('[data-url]')
  end

  it 'will show an empty category' do
    empty_category = create(:category)
    visit '/admin/categories/childless'

    expect(page).to have_css('[data-url]')
    expect(page).to have_text(empty_category.name)
  end
end
