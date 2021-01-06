# frozen_string_literal: true

module NestableHelper
  include ActionView::Helpers::TranslationHelper

  def nested_tree_nodes(tree_nodes = [])
    return if tree_nodes.nil?

    nodes = tree_nodes.map do |tree_node, sub_tree_nodes|
      li_classes = 'list-group-item dd-item dd3-item dd-collapsed'

      content_tag(:li, class: li_classes, 'data-id': tree_node.id) do
        output = content_tag :div, 'drag', class: 'dd-handle dd3-handle'
        output += button_tag '+', class: 'dd-expand', data: { action: 'expand' }
        output += button_tag '-', class: 'dd-collapse', data: { action: 'collapse' }
        output += content_tag :div, class: 'dd3-content' do
          content_tag :div, class: %w[dd-flex] do
            content = content_tag :div, object_label(tree_node), class: %i[dd-label]
            content += content_tag :div, class: %i[dd-extras] do
              extras = children_count(sub_tree_nodes)
              extras += link_to 'Edit', edit_admin_category_path(tree_node.id), class: %i[dd-link]
              extras += link_to 'View detail', '#', class: %i[dd-link view-detail]
              extras
            end
            content
          end
        end

        output += content_tag :div, class: %i[dd-details hidden] do
          rows = content_tag :div, class: %i[details-row] do
            row = content_tag :span, 'Description', class: %i[title]
            row += content_tag :span, tree_node.description, class: %i[content]
            row
          end
          rows += content_tag :div, class: %i[details-row] do
            row = content_tag :span, 'Created', class: %i[title]
            row += content_tag :span, l(tree_node.created_at, format: :npd_long), class: %i[content]
            row
          end
          rows += content_tag :div, class: %i[details-row] do
            row = content_tag :span, 'Updated', class: %i[title]
            row += content_tag :span, l(tree_node.updated_at, format: :npd_long), class: %i[content]
            row
          end
          rows
        end

        content = sub_tree_nodes&.any? ? nested_tree_nodes(sub_tree_nodes) : ''
        output += content_tag(:ol, content, class: 'list-group nested-sortable dd-list', 'data-id': tree_node.id)
        output
      end
    end

    nodes.join.html_safe
  end

  def object_label(tree_node)
    tree_node.name
  end

  def children_count(sub_tree_nodes)
    content_tag :span, "#{sub_tree_nodes.count} categories", class: %i[dd-count]
  end
end
