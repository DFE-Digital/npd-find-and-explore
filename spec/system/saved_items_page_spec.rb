# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Saved Items page', type: :system do
  it 'Will show the saved items page' do
    visit '/saved_items'
    expect(page).to have_text('My List', count: 3)
    expect(page).to have_text(
      'As you explore information about the type of data held in the NPD, ' \
      'you can create a \'My List\' of data items that are of interest to you. ' \
      'You can export this list into a .xlsx or .ods file, which may help when ' \
      'completing the NPD Data Tables that should be submitted when applying to ' \
      'DfE for NPD data.'
    )
  end

  context 'with saved items' do
    before :each do
      DataElement.destroy_all
      Concept.destroy_all
      Category.destroy_all

      create_list(:category, 2, :with_subcategories_concepts_and_data_elements)
    end

    let(:concept) { Concept.first }

    it 'Will have the saved items' do
      visit "/concepts/#{concept.id}"
      find('#data-element-all', visible: :all).click

      visit '/saved_items'

      concept.data_elements.each do |element|
        expect(page).to have_text(element.unique_alias)
        expect(page).to have_text(element.description)
      end
    end

    it 'Will remove a saved item' do
      visit "/concepts/#{concept.id}"
      find('#data-element-all', visible: :all).click

      data_element = concept.data_elements.first

      visit '/saved_items'
      find("[id='#{data_element.id}']").click

      expect(page).not_to have_text(data_element.unique_alias)
    end
  end
end
