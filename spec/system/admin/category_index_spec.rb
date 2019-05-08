# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Categories Index', type: :system do
  let(:password) { 'password' }
  let(:admin_user) { AdminUser.create!(email: 'admin@test.com', password: password) }

  before do
    DataElement.destroy_all
    Concept.destroy_all
    Category.destroy_all
    admin_user
    create(:category, :with_subcategories_concepts_and_data_elements)
    PgSearch::Multisearch.rebuild(Category)
    PgSearch::Multisearch.rebuild(Concept)

    visit '/admin'
    fill_in('admin_user_email', with: admin_user.email)
    fill_in('admin_user_password', with: password)
    click_on('Log in')
  end

  it 'Has search' do
    visit '/admin/categories'
    expect(page).to have_field('search')
  end

  it 'Will find categories' do
    visit '/admin/categories'
    search = page.find('#search').native
    search.send_keys(Category.first.name)
    search.send_key "\n"

    expect(page).to have_text(Category.first.name)
    expect(page).to have_text(Category.first.description[0, 50])
  end
end
