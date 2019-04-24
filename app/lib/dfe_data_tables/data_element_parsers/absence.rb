# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class Absence < Sheet
    private

      def regex
        /Absence#{YEARS_REGEX}/
      end
    end
  end
end
