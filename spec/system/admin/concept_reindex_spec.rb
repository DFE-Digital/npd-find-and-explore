# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Concepts Reindex', type: :system do
  let(:password) { 'paSSw0rd!' }
  let(:admin_user) { AdminUser.create!(email: 'admin@test.com', password: password) }

  before do
    DataElement.destroy_all
    Concept.destroy_all
    Category.destroy_all

    admin_user
    create(:category, :with_subcategories_concepts_and_data_elements)
    Concept.update_all(tsvector_content_tsearch: nil)

    visit '/admin'
    fill_in('admin_user_email', with: admin_user.email)
    fill_in('admin_user_password', with: password)
    click_on('Log in')
  end

  it 'Will reindex the concepts' do
    visit '/admin/concepts/reindex'

    click_on 'Reindex Concepts'
    expect(page).to have_text('The concepts were reindexed correctly')
    expect(Concept.first.tsvector_content_tsearch).not_to be_nil
  end
end
