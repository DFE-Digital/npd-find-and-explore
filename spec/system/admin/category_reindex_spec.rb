# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Categories Reindex', type: :system do
  let(:password) { 'paSSw0rd!' }
  let(:admin_user) { AdminUser.create!(email: 'admin@test.com', password: password) }

  before do
    DataElement.destroy_all
    Concept.destroy_all
    Category.destroy_all

    admin_user
    create(:category, :with_subcategories_concepts_and_data_elements)
    Category.update_all(tsvector_content_tsearch: nil)

    visit '/admin'
    fill_in('admin_user_email', with: admin_user.email)
    fill_in('admin_user_password', with: password)
    click_on('Log in')
  end

  it 'Will reindex the categories' do
    visit '/admin/categories/reindex'

    click_on 'Reindex Categories'
    expect(page).to have_text('The categories were reindexed correctly')
    expect(Category.first.tsvector_content_tsearch).not_to be_nil
  end
end
