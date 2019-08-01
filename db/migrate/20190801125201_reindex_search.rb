# frozen_string_literal: true

class ReindexSearch < ActiveRecord::Migration[5.2]
  def up
    PgSearch::Multisearch.rebuild(Concept)
    PgSearch::Multisearch.rebuild(Category)
  end

  def down
    PgSearch::Multisearch.rebuild(Concept)
    PgSearch::Multisearch.rebuild(Category)
  end
end
