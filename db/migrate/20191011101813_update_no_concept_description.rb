# frozen_string_literal: true

class UpdateNoConceptDescription < ActiveRecord::Migration[5.2]
  def up
    # 2020-01-28 Kept as historical documentation, removing the Globalize gem renders this inoperable
    # at this point of the development
    # PgSearch.disable_multisearch do
    #   Concept.find_by(name: 'No Concept')
    #          &.update(description: 'This Concept is used to house data elements that are waiting to be categorised')
    # end
  end

  def down
    # nothing to do
  end
end
