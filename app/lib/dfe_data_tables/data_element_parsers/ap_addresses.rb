# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class ApAddresses < Sheet
    private

      def regex
        /^(AP_Addresses|AP Addresses|APAddresses)/i
      end
    end
  end
end
