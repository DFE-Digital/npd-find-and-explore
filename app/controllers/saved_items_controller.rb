# frozen_string_literal: true

# Saved Items main page
class SavedItemsController < ApplicationController
  include BreadcrumbBuilder
  include ActionView::Helpers::UrlHelper
  include ApplicationHelper

  HEADERS_ROW = ['Dataset', 'NPD Alias', 'Date Collected', 'Sensitivity',
                 'Identifiability', 'Years Required'].freeze

  helper_method :headers_row, :row_cells

  def index
    @title = t('saved_data.my_list.title')
    @title_size = 'xl'
    @description = t('saved_data.my_list.description')
    custom_breadcrumbs_for(steps: [{ name: 'My List', path: saved_items_path }])

    render action: :index
  end

  def saved_items
    render partial: 'saved_items', layout: false, locals: { grouped_elements: grouped_elements }
  end

  def export_to_csv
    filename = "NPD My List #{DateTime.now.strftime('%d-%m-%Y %H_%M')}.#{params.dig(:format)}"
    cookies['download'] = { value: 'download-saved-items' }

    respond_to do |format|
      format.xlsx do
        render xlsx: 'export_to_xlsx.xlsx.axlsx', disposition: :inline, filename: filename,
               locals: { grouped_elements: grouped_elements }
      end
      format.ods do
        send_data export_to_ods,
                  disposition: :inline, filename: filename,
                  type: 'application/vnd.oasis.opendocument.spreadsheet'
      end
      format.any do
        render :unsupported_media_type
      end
    end
  end

private

  def elements
    @elements ||= params.permit(elements: {}).to_h.dig(:elements)
  end

  def grouped_elements
    @grouped_elements ||= elements
                            &.map { |k, v| v.merge('object' => DataElement.find_by(id: k)) }
                            &.select { |e| e.dig(:object).present? }
                            &.group_by { |e| e.dig(:object).datasets.first } || []
  end

  def export_to_ods
    ods = RODF::Spreadsheet.new
    grouped_elements.each do |dataset, elements|
      table = ods.table(dataset.tab_name[0, 31])
      table.add_rows(HEADERS_ROW)
      elements.each do |element|
        data_item = element['object']
        table.add_rows(row_cells(dataset, data_item))
      end
    end
    ods.bytes
  end

  def headers_row
    HEADERS_ROW
  end

  def row_cells(dataset, data_item)
    [
      dataset.tab_name,
      data_item.unique_alias,
      [academic_year(data_item.academic_year_collected_from),
       academic_year(data_item.academic_year_collected_to)].join(' to '),
      data_item.sensitivity,
      data_item.identifiability,
      ''
    ].flatten
  end
end
