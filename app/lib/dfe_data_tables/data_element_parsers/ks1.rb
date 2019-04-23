# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class Ks1 < Sheet
    private

      def regex
        /KS1#{YEARS_REGEX}/
      end
    end
  end
end
