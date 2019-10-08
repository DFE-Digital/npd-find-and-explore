# frozen_string_literal: true

module Administrate
  class OrderBase < Administrate::Order
    def apply(relation)
      return order_by_association(relation) unless reflect_association(relation).nil?

      order = "#{relation.table_name}.#{attribute} #{direction}"

      return relation.reorder(order) if relation.columns_hash.keys.include?(attribute.to_s)

      return reorder(relation) if should_reorder?(relation)

      relation
    end

  private

    def order_by_association(relation)
      return order_by_count(relation) if has_many_attribute?(relation)

      return order_by_name(relation) if belongs_to_translated_attribute?(relation)

      return order_by_id(relation) if belongs_to_attribute?(relation)

      relation
    end

    def order_by_name(relation)
      relation
        .joins(attribute.to_sym => :translations)
        .reorder("#{attribute}_translations.name" => direction)
    end

    def should_reorder?(relation)
      attribute.present? &&
        (relation.first.respond_to?(:translations) &&
         relation.first.translations.first.respond_to?(attribute))
    end

    def reorder(relation)
      relation.reorder(attribute => direction)
    end

    def belongs_to_translated_attribute?(relation)
      reflect_association(relation).macro == :belongs_to &&
        relation.first.send(attribute).respond_to?(:translations) &&
        relation.first.send(attribute).translations.first.respond_to?(:name)
    end
  end
end
