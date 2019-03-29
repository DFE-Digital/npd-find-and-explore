# frozen_string_literal: true

class SearchController < ApplicationController
  def index
    @results = search
    render action: :index
  end

private

  def search
    Search.search(search_params[:search])
          .includes(result: %i[translations])
          .map(&:result).uniq
  end

  def search_params
    params.permit(:search)
  end
end
