# frozen_string_literal: true

class DatasetsController < ApplicationController
  def show
    @dataset = Dataset
               .includes(:translations, :data_elements)
               .find(params.require(:id))

    @title = @dataset.name
    @description = @dataset.description
  end
end
