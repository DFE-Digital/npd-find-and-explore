# frozen_string_literal: true

class SearchController < ApplicationController
  def index
    @results = search
    render action: :index
  end

private

  def search
    PgSearch.multisearch(search_params[:search]).includes(searchable: %i[translations])
  end

  def search_params
    params.permit(:search)
  end
end
