# frozen_string_literal: true

# Saved Items main page
class SavedItemsController < ApplicationController
  include BreadcrumbBuilder
  include ActionView::Helpers::UrlHelper

  def index
    @title = t('saved_data.my_list.title')
    @title_size = 'xl'
    @description = t('saved_data.my_list.description')
    breadcrumbs_for(custom: { name: 'My List', path: saved_items_path })

    render action: :index
  end

  def saved_items
    render partial: 'saved_items', layout: false, locals: { grouped_elements: grouped_elements, range_errors: [] }
  end

  def export_to_csv
    filename = "NPD My List #{DateTime.now.strftime('%d-%m-%Y %H_%M')}.xlsx"
    cookies['download'] = { value: 'download-saved-items' }

    render xlsx: 'export_to_xlsx.xlsx.axlsx', disposition: :inline, filename: filename,
           locals: { grouped_elements: grouped_elements }
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
end
