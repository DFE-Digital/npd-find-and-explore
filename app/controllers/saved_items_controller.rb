# frozen_string_literal: true

# Saved Items main page
class SavedItemsController < ApplicationController
  include BreadcrumbBuilder
  include ActionView::Helpers::UrlHelper
  include ApplicationHelper

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
      table.add_rows(['Dataset', 'NPD Alias', 'Date Collected', 'Sensitivity',
                      'Identifiability', 'Notes'])
      elements.each do |element|
        de = element['object']
        table.add_rows([
          dataset.tab_name,
          de.unique_alias,
          [academic_year(de.academic_year_collected_from),
           academic_year(de.academic_year_collected_to)].join(' to '),
          de.sensitivity,
          de.identifiability,
          element['notes']
        ].flatten)
      end
    end
    ods.bytes
  end
end
