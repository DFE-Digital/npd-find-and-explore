# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class PruCensus < Sheet
    private

      def regex
        /PRU_Census#{YEARS_REGEX}/
      end
    end
  end
end
