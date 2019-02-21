# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('spec', 'controllers', 'concerns', 'with_breadcrumbs_spec.rb')

RSpec.describe CategoriesController, type: :controller do
  it_behaves_like 'with_breadcrumbs'
end
