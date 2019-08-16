# frozen_string_literal: true

module DataTable
  class ApAddresses < Tab
  private

    def tab_label
      'AP Addresses'
    end

    def regex
      /^(AP_Addresses|AP Addresses|APAddresses)/i
    end
  end
end
