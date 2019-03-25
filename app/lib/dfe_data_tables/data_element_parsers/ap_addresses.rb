# frozen_string_literal: true

require_relative 'sheet'

module DfEDataTables
  module DataElementParsers
    class ApAddresses < Sheet
      private

      def regex
        /AP addresses_\d{2}_\d{2}/
      end
    end
  end
end
