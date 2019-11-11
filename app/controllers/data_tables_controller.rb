# frozen_string_literal: true

class DataTablesController < ApplicationController
  include BreadcrumbBuilder

  # def index
  #   Show a list of all data table records sorted by creation date, so that
  #   users will be able to access historical data
  # end

  def show
    # Add id parsing when we'll need to let the user download data tables other
    # than the latest
    @title = t('data_tables.download.title')
    @data_table = DataTable::Upload.where(successful: true).order(created_at: :asc).last

    respond_to do |format|
      format.html # show.html.erb
      format.xlsx { redirect_to rails_blob_path(@data_table.data_table, disposition: :attachment) }
    end
  end
end
