# frozen_string_literal: true

# Saved Items main page
class SavedItemsController < ApplicationController
  include ActionView::Helpers::UrlHelper

  def index
    @title = t('saved_data.my_list.title')
    @title_size = 'xl'
    @description = t('saved_data.my_list.description',
                     link: link_to(t('saved_data.my_list.link'),
                                   Rails.configuration.outgoing_links.dig('applying_for_access') || 'https://www.google.com',
                                   class: 'govuk-link',
                                   data: { outgoing_link: true,
                                           outgoing_page: 'Applying for Access' }))

    render action: :index
  end

  def saved_items
    render action: :saved_items, layout: false, locals: { grouped_elements: grouped_elements }
  end

  def export_to_csv
    render action: :saved_items, layout: false, locals: { grouped_elements: grouped_elements }
  end

private

  def elements
    params.permit(elements: {}).to_h.dig(:elements)
  end

  def grouped_elements
    elements
      &.map { |k, v| v.merge('object' => DataElement.find(k)) }
      &.group_by { |e| e.dig(:object).datasets.first } || []
  end
end
