# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class Plams < Sheet
    private

      def regex
        /PLAMS#{YEARS_REGEX}/
      end
    end
  end
end
