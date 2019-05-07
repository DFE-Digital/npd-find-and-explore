# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Concepts Index', type: :system do
  let(:password) { 'password' }
  let(:admin_user) { AdminUser.create!(email: 'admin@test.com', password: password) }

  before do
    admin_user
    create_list(:category, 2, :with_subcategories_concepts_and_data_elements)
    PgSearch::Multisearch.rebuild(Category)
    PgSearch::Multisearch.rebuild(Concept)

    visit '/admin'
    fill_in('admin_user_email', with: admin_user.email)
    fill_in('admin_user_password', with: password)
    click_on('Log in')
  end

  it 'Has search' do
    visit '/admin/concepts'
    expect(page).to have_field('search')
  end

  it 'Will find concepts' do
    visit '/admin/concepts'
    search = page.find('#search').native
    search.send_keys(Concept.first.name)
    search.send_key "\n"

    expect(page).to have_text(Concept.first.name)
    expect(page).to have_text(Concept.first.category.name)
  end

  it 'Will find concepts by element' do
    visit '/admin/concepts'
    search = page.find('#search').native
    search.send_keys(DataElement.first.source_table_name)
    search.send_key "\n"

    expect(page).to have_field('search')
    expect(page).to have_text(DataElement.first.concept.name)
    expect(page).to have_text(DataElement.first.concept.category.name)
  end
end
