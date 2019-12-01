# frozen_string_literal: true

class DatasetsController < ApplicationController
  before_action :find_dataset, only: %i[show data_elements]

  def show
    @title = @dataset.name
    @description = @dataset.description
  end

  def data_elements
    render :data_elements, layout: false
  end

private

  def find_dataset
    @dataset = Dataset
               .includes(:data_elements)
               .find(params.require(:id))
  end
end
