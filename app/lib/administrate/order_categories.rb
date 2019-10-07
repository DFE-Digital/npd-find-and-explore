# frozen_string_literal: true

module Administrate
  class OrderCategories < Administrate::Order
    def order_by_count(relation)
      relation
        .left_joins(attribute.to_sym)
        .group(:id, 'category_translations.name')
        .reorder("COUNT(#{attribute}.id) #{direction}")
    end
  end
end
