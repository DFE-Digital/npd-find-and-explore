# frozen_string_literal: true

require_relative 'sheet'

module DfEDataTables
  module Parsers
    class ScAddresses < Sheet
      private

      def regex
        /SC_Addresses#{YEARS_REGEX}/
      end
    end
  end
end
