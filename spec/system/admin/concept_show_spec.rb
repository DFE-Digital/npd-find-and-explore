# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Concepts Show', type: :system do
  let(:password) { 'paSSw0rd!' }
  let(:admin_user) { AdminUser.create!(email: 'admin@test.com', password: password) }

  before do
    DataElement.destroy_all
    Concept.destroy_all
    Category.destroy_all

    admin_user
    create(:category, :with_subcategories_concepts_and_data_elements)
    Category.rebuild_pg_search_documents
    Concept.rebuild_pg_search_documents

    visit '/admin'
    fill_in('admin_user_email', with: admin_user.email)
    fill_in('admin_user_password', with: password)
    click_on('Log in')
  end

  it 'Will have the breadcrumbs' do
    concept = Concept.first
    breadcrumbs = ['Home', concept.category.ancestors.map(&:name).reverse, concept.category.name]
                  .flatten
                  .join("\n")

    visit "/admin/concepts/#{concept.id}"
    expect(page).to have_text(breadcrumbs)
  end
end
