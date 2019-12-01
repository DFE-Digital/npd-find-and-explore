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
  include PgSearch::Model

  has_many :concepts, dependent: :destroy, inverse_of: :category

  before_destroy :reassign_concepts, prepend: true

  scope :real, -> { where.not(name: 'No Category') }

  has_ancestry orphan_strategy: :rootify

  multisearchable against: %i[name description]

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

  def create_or_update_pg_search_document
    conn = ActiveRecord::Base.connection
    if !pg_search_document
      conn.execute <<-SQL
        INSERT INTO pg_search_documents (searchable_type, searchable_id, content,
          searchable_name, searchable_created_at, searchable_updated_at, created_at, updated_at)
        SELECT 'Category' AS searchable_type,
        #{conn.quote(id)} AS searchable_id,
        setweight(to_tsvector(#{conn.quote(name)}), 'A') ||
          setweight(to_tsvector(#{conn.quote(description)}), 'B') AS content,
        #{conn.quote(name)} AS searchable_name,
        #{conn.quote(created_at)} AS searchable_created_at,
        #{conn.quote(updated_at)} AS searchable_updated_at,
        now() AS created_at,
        now() AS updated_at
      SQL
    elsif should_update_pg_search_document?
      conn.execute <<-SQL
        UPDATE pg_search_documents
        SET
          content = setweight(to_tsvector(#{conn.quote(name)}), 'A') ||
                    setweight(to_tsvector(#{conn.quote(description)}), 'B'),
          searchable_name = #{conn.quote(name)},
          searchable_created_at = #{conn.quote(created_at)},
          searchable_updated_at = #{conn.quote(updated_at)},
          updated_at = NOW()
        WHERE searchable_type = 'Category' AND searchable_id = #{conn.quote(id)}
      SQL
    end
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

  def self.rebuild_pg_search_documents
    connection.execute <<-SQL
      INSERT INTO pg_search_documents (searchable_type, searchable_id, content,
        searchable_name, searchable_created_at, searchable_updated_at, created_at, updated_at)
      SELECT 'Category' AS searchable_type,
      categories.id AS searchable_id,
      setweight(to_tsvector(categories.name), 'A') ||
      setweight(to_tsvector(categories.description), 'B')
      AS content,
      categories.name AS searchable_name,
      MIN(categories.created_at) AS searchable_created_at,
      MIN(categories.updated_at) AS searchable_updated_at,
      now() AS created_at,
      now() AS updated_at

      FROM categories
      GROUP BY categories.id
    SQL
  end
end
