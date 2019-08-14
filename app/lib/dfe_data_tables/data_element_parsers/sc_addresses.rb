# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class ScAddresses < Sheet
    private

      def regex
        /^(SC_Addresses|SC Addresses|SCAddresses)/i
      end
    end
  end
end
