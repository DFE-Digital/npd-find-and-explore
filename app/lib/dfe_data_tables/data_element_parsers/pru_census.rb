# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class PruCensus < Sheet
    private

      def regex
        /^(PRU_Census|PRU Census|PRUCensus)/i
      end
    end
  end
end
