# frozen_string_literal: true

require 'administrate/field/base'

class HasManySortedField < Administrate::Field::HasMany
private

  def candidate_resources
    scope = if options.key?(:includes)
              includes = options.fetch(:includes)
              associated_class.includes(*includes).all
            else
              associated_class.all
            end

    order = options.delete(:order)
    order ? scope.reorder(order) : scope
  end
end
