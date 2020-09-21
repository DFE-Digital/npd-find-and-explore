# frozen_string_literal: true

# Categories are used to group related Concepts (and therefore Data Elements), for example:
#
#  Socio Economic Status (category)
#   |- IDACI (category)
#   |- Free School Meals (category)
#       |- Eligible for FSM in the past 6 years? (concept)
#
# A category contains one or more categories in a nested tree.
# A leaf-category (one without sub-categories) contains one or more
# concepts.
class Category < Versioned
  include SanitizeSpace

  has_many :concepts, dependent: :destroy, inverse_of: :category

  before_destroy :reassign_concepts, prepend: true
  before_create :sort_categories

  scope :real, -> { where.not(name: 'No Category') }

  has_ancestry orphan_strategy: :rootify

  def child_categories
    children.count
  end

  def reassign_concepts
    return true if concepts.count.zero?
    raise(ActiveRecord::NotNullViolation, 'Cannot delete "No Category" with concepts') if name == 'No Category' && concepts.count.positive?

    no_category = Category.find_or_create_by(name: 'No Category')
    concepts.each do |concept|
      concept.update(category: no_category)
    end
    reload
  end

  def self.childless
    join_condition = '(regexp_match(children.ancestry, \'[[:alnum:]-]+\Z\')) = regexp_split_to_array(categories.id::"varchar", \'/\')'
    search = arel_table
             .project('categories.id AS id, COUNT(children.id) AS children_count, COUNT(concepts) AS concepts_count')
             .join(arel_table.alias(Arel.sql('children')), Arel::Nodes::OuterJoin).on(join_condition)
             .join(Concept.arel_table, Arel::Nodes::OuterJoin).on('concepts.category_id = categories.id')
             .group('categories.id')

    where("categories.id IN (SELECT id FROM (#{search.to_sql}) AS search WHERE search.children_count = 0 AND search.concepts_count = 0)")
  end

private

  def sort_categories
    return unless is_root?

    Category.roots.each { |root| root.update(position: (root.position || 1) + 1) }
    self.position = 1
  end
end
