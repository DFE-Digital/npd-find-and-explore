# frozen_string_literal: true

module NestableHelper
  include ActionView::Helpers::TranslationHelper

  def nested_tree_nodes(categories = [])
    return '' if categories.empty?

    nodes = categories.map do |category|
      li_classes = %w[list-group-item dd-item dd3-item dd-collapsed]
      li_classes.push 'dd-concept' if category.children.empty? && category.concepts.any?

      content_tag :li, class: li_classes, 'data-id': category.id do
        output = content_tag :div, 'drag', class: %w[dd-handle dd3-handle]
        output += button_tag '+', class: %w[dd-expand], data: { action: 'expand' }
        output += button_tag '-', class: %w[dd-collapse], data: { action: 'collapse' }
        output += content_tag :div, class: %w[dd-content dd3-content] do
          content_tag :div, class: %w[dd-flex] do
            content = content_tag :div, object_label(category), class: %w[dd-label]
            content += content_tag :div, class: %w[dd-extras] do
              extras = children_count(category)
              extras += link_to 'Edit', edit_admin_category_path(category.id), class: %w[dd-link]
              extras += link_to 'View detail', '#', class: %w[dd-link view-detail]
              extras
            end
            content
          end
        end

        output += details(category)

        content = nested_tree_nodes(category.children)
        content += nested_concepts(category)
        output += content_tag(:ol, content.html_safe, class: %w[list-group nested-sortable dd-list], 'data-id': category.id)
        output
      end
    end

    nodes.join.html_safe
  end

  def nested_concepts(category)
    nodes = category.concepts.map do |concept|
      li_classes = %w[list-group-item dd-item dd4-item dd-collapsed dd-concept]

      content_tag :li, class: li_classes, 'data-id': "concept-#{concept.id}" do
        output = content_tag :div, 'drag', class: %w[dd-handle dd4-handle]
        output += content_tag :div, class: %w[dd-content dd4-content] do
          content_tag :div, class: %w[dd-flex] do
            content = content_tag :div, object_label(concept), class: %w[dd-label]
            content += content_tag :div, class: %w[dd-extras] do
              extras = content_tag :span, "#{concept.data_elements.count} data items", class: %w[dd-count]
              extras += link_to 'Edit', edit_admin_concept_path(concept.id), class: %w[dd-link]
              extras += link_to 'View detail', '#', class: %w[dd-link view-detail]
              extras
            end
            content
          end
        end

        output += details(concept)
        output
      end
    end

    nodes.join.html_safe
  end

  def object_label(category)
    category.name
  end

  def children_count(category)
    if category.concepts.any?
      content_tag :span, "#{category.concepts.count} concepts", class: %w[dd-count]
    else
      content_tag :span, "#{category.children.count} categories", class: %w[dd-count]
    end
  end

  def details(element)
    content_tag :div, class: %w[dd-details hidden] do
      rows = content_tag :div, class: %w[details-row] do
        row = content_tag :span, 'Description', class: %w[title]
        row += content_tag :span, element.description, class: %w[content]
        row
      end
      rows += content_tag :div, class: %w[details-row] do
        row = content_tag :span, 'Created', class: %w[title]
        row += content_tag :span, l(element.created_at, format: :npd_long), class: %w[content]
        row
      end
      rows += content_tag :div, class: %w[details-row] do
        row = content_tag :span, 'Updated', class: %w[title]
        row += content_tag :span, l(element.updated_at, format: :npd_long), class: %w[content]
        row
      end
      rows
    end
  end
end
