# frozen_string_literal: true

module DataTable
  class AltProvision < Tab
  private

    def tab_label
      'Alt Provision'
    end

    def regex
      /^(Alt_Provision|Alt Provision|AltProvision)/i
    end
  end
end
