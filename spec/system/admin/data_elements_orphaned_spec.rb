# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Data Elements Orphaned', type: :system do
  let(:password) { 'paSSw0rd!' }
  let(:admin_user) { AdminUser.create!(email: 'admin@test.com', password: password) }

  before do
    DataElement.destroy_all
    Concept.destroy_all
    Category.destroy_all

    admin_user
    create(:concept, :with_data_elements)

    visit '/admin'
    fill_in('admin_user_email', with: admin_user.email)
    fill_in('admin_user_password', with: password)
    click_on('Log in')
  end

  it 'has no orphaned data elements' do
    visit '/admin/data_elements/orphaned'

    expect(page).not_to have_css('[data-url]')
  end

  it 'will show an orphaned data element' do
    orphaned_element = DataElement.first
    ActiveRecord::Base.connection.execute("UPDATE data_elements SET concept_id = NULL WHERE id = '#{orphaned_element.id}'")

    visit '/admin/data_elements/orphaned'

    expect(page).to have_css('[data-url]')
    expect(page).to have_text(orphaned_element.datasets.first.name)
    expect(page).to have_text(orphaned_element.unique_alias)
  end
end
