# frozen_string_literal: true

# Read resources for the DataElement details pages
class DataElementsController < ApplicationController
  include BreadcrumbBuilder
  include ApplicationHelper

  def show
    @data_element = DataElement
                    .includes(%i[concept datasets])
                    .find(params.require(:id))

    @title = @data_element.npd_alias
    @description = @data_element.description
    @skip_shared_header = true
    back_breadcrumbs
  end
end
