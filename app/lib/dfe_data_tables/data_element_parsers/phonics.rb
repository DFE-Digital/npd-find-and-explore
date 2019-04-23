# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class Phonics < Sheet
    private

      def regex
        /Phonics#{YEARS_REGEX}/
      end
    end
  end
end
