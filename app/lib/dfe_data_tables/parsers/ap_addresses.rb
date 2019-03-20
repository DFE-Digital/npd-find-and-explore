# frozen_string_literal: true

require_relative 'sheet'

module DfEDataTables
  module Parsers
    class ApAddresses < Sheet
      private

      def regex
        /AP addresses_\d{2}_\d{2}/
      end
    end
  end
end
