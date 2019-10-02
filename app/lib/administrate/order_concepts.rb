# frozen_string_literal: true

module Administrate
  class OrderConcepts < Administrate::Order
    def order_by_count(relation)
      relation
        .left_joins(attribute.to_sym)
        .group(:id, 'concept_translations.name')
        .reorder("COUNT(#{attribute}.id) #{direction}")
    end
  end
end
