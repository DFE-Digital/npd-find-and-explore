# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class Eyfsp < Sheet
    private

      def regex
        /EYFSP#{YEARS_REGEX}/
      end
    end
  end
end
