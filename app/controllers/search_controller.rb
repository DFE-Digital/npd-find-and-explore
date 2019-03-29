# frozen_string_literal: true

class SearchController < ApplicationController
  def index
    @results = search
    render action: :index
  end

private

  def search
    PgSearch.multisearch(search_params[:search])
            .map { |s| s.searchable.is_a?(DataElement) ? s.searchable.concept : s.searchable }
            .uniq
  end

  def search_params
    params.permit(:search)
  end
end
