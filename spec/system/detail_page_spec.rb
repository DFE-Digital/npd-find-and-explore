# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Category hierarchy', type: :system do
  let(:concept) { create(:concept) }

  it 'View the concept detail page' do
    visit concept_path(concept)

    expect(page).to have_text(concept.name)
    expect(page).to have_text(concept.description)
  end

  it 'Shows the breadcrumb trail' do
    visit concept_path(concept)

    expect(page).to have_link('Home', href: categories_path)
    expect(page).to have_link(concept.category.name, href: category_path(concept.category))
  end
end
