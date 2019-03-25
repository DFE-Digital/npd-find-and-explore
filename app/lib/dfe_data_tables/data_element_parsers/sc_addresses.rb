# frozen_string_literal: true

require_relative 'sheet'

module DfEDataTables
  module DataElementParsers
    class ScAddresses < Sheet
    private

      def regex
        /SC_Addresses#{YEARS_REGEX}/
      end
    end
  end
end
