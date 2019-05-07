# frozen_string_literal: true

require 'administrate/field/base'

class BreadcrumbField < Administrate::Field::BelongsTo
  include ActionView::Helpers::UrlHelper
  include ActionDispatch::Routing::UrlFor

  def breadcrumbs
    path_to(data).reverse
  end

private

  def path_to(parent)
    return [parent] if parent.parent.blank?

    [parent, path_to(parent.parent)].flatten
  end
end
