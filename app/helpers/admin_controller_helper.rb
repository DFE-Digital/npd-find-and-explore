# frozen_string_literal: true

module AdminControllerHelper
  def orphaned_actions?
    params.dig(:controller) == 'admin/data_elements' &&
      /orphaned/ =~ params.dig(:action)
  end
end
