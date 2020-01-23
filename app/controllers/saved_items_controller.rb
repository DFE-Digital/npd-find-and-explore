# frozen_string_literal: true

# Saved Items main page
class SavedItemsController < ApplicationController
  include BreadcrumbBuilder
  include ActionView::Helpers::UrlHelper

  def index
    @title = t('saved_data.my_list.title')
    @title_size = 'xl'
    @description = t('saved_data.my_list.description',
                     link: link_to(t('saved_data.my_list.link'),
                                   Rails.configuration.outgoing_links.dig('applying_for_access') || '',
                                   class: 'govuk-link',
                                   data: { outgoing_link: true,
                                           outgoing_page: 'Applying for Access' }))
    breadcrumbs_for(custom: { name: 'My List', path: saved_items_path})

    render action: :index
  end

  def saved_items
    render partial: 'saved_items', layout: false, locals: { grouped_elements: grouped_elements, range_errors: [] }
  end

  def export_to_csv
    if invalid_ranges.any?
      render action: :index, locals: { grouped_elements: grouped_elements, range_errors: invalid_ranges }
    else
      filename = "NPD My List #{DateTime.now.strftime('%d-%m-%Y %H_%M')}.xlsx"
      cookies['download'] = { value: 'download-saved-items' }

      render xlsx: 'export_to_csv.xlsx.axlsx', disposition: :inline, filename: filename,
             locals: { grouped_elements: grouped_elements }
    end
  end

private

  def elements
    @elements ||= params.permit(elements: {}).to_h.dig(:elements)
  end

  def grouped_elements
    @grouped_elements ||= elements
                            &.map { |k, v| v.merge('object' => DataElement.find(k)) }
                            &.group_by { |e| e.dig(:object).datasets.first } || []
  end

  def invalid_ranges
    @invalid_ranges ||= begin
                          ranges = elements.map do |_key, el|
                            el.dig(:years_from) > el.dig(:years_to) ? range_error(el.dig(:npd_alias)) : nil
                          end
                          ranges.compact
                        end
  end

  def range_error(npd_alias)
    "#{npd_alias}: Start date must be before end date"
  end
end
