# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class Absence < Sheet
    private

      def regex
        /^Absence/i
      end
    end
  end
end
