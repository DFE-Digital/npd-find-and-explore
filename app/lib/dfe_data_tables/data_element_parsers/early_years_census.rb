# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class EarlyYearsCensus < Sheet
    private

      def regex
        /^(Early_Years_Census|Early Years Census|EarlyYearsCensus)/i
      end
    end
  end
end
