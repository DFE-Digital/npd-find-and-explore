# frozen_string_literal: true

require 'rails_helper'

# TODO: it would be nice to test this concern properly
RSpec.shared_examples_for 'with_breadcrumbs' do
  let(:model) { described_class } # the class that includes the concern

  xdescribe '#breadcrumbs_for' do
    it 'builds a category tree' do
      described_class.new.breadcrumbs_for(category_leaf: nil, concept: nil)
      # TODO: something with breadcrumb_trail ?
    end
  end
end
