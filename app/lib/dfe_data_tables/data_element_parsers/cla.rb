# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class Cla < Sheet
    private

      def regex
        /CLA#{YEARS_REGEX}/
      end
    end
  end
end
