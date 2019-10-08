# frozen_string_literal: true

module Administrate
  class OrderConcepts < Administrate::Order
    def apply(relation)
      return order_by_association(relation) unless reflect_association(relation).nil?

      order = "#{relation.table_name}.#{attribute} #{direction}"

      return relation.reorder(order) if relation.columns_hash.keys.include?(attribute.to_s)

      return reorder(relation) if should_reorder?(relation)

      relation
    end

  private

    def should_reorder?(relation)
      attribute.present? &&
        (relation.first.respond_to?(:translations) &&
         relation.first.translations.first.respond_to?(attribute))
    end

    def order_by_count(relation)
      relation
        .left_joins(attribute.to_sym)
        .group(:id, 'concept_translations.name')
        .reorder("COUNT(#{attribute}.id) #{direction}")
    end

    def reorder(relation)
      relation.reorder(attribute => direction)
    end
  end
end
