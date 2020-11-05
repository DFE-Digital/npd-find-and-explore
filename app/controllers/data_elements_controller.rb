# frozen_string_literal: true

# Read resources for the DataElement details pages
class DataElementsController < ApplicationController
  include BreadcrumbBuilder
  include ApplicationHelper

  def show
    @data_element = DataElement
                    .includes(%i[concept datasets])
                    .find(params.require(:id))

    @title = @data_element.title
    @description = @data_element.description
    custom_breadcrumbs_for(steps: [{ name: @data_element.title, path: data_element_path(@data_element) }])
  end
end
