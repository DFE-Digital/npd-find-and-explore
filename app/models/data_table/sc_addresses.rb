# frozen_string_literal: true

module DataTable
  class ScAddresses < Tab
  private

    def tab_label
      'SC Addresses'
    end

    def regex
      /^(SC_Addresses|SC Addresses|SCAddresses)/i
    end
  end
end
