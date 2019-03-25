# frozen_string_literal: true

require_relative 'sheet'

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
