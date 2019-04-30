# frozen_string_literal: true

module NestableHelper
  def nested_tree_nodes(tree_nodes = [])
    return if tree_nodes.nil?

    nodes = tree_nodes.map do |tree_node, sub_tree_nodes|
      li_classes = 'dd-item dd3-item'

      content_tag(:li, class: li_classes, 'data-id': tree_node.id) do
        output = content_tag :div, 'drag', class: 'dd-handle dd3-handle'
        output += content_tag :div, class: 'dd3-content' do
          link_to object_label(tree_node), edit_admin_category_path(tree_node.id)
        end

        output += content_tag(:ol, nested_tree_nodes(sub_tree_nodes), class: 'dd-list') if sub_tree_nodes&.any?
        output
      end
    end
    nodes.join.html_safe
  end

  def object_label(tree_node)
    tree_node.name
  end
end
