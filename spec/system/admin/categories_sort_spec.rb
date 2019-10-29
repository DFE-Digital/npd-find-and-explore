# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Categories Import', type: :system do
  let(:password) { 'paSSw0rd!' }
  let(:admin_user) { AdminUser.create!(email: 'admin@test.com', password: password) }

  before do
    DataElement.destroy_all
    Concept.destroy_all
    Category.destroy_all
    create_list(:category, 10, :with_subcategories_concepts_and_data_elements)

    admin_user

    visit '/admin'
    fill_in('admin_user_email', with: admin_user.email)
    fill_in('admin_user_password', with: password)
    click_on('Log in')
  end

  it 'Will show the sort page' do
    visit 'admin/categories/tree'

    expect(page).to have_text('Sort Categories')
    Category.roots.each do |root|
      expect(page).to have_text(root.name)
    end
    expect(page).to have_css('li div.dd3-content + ol.dd-list')
  end
end
