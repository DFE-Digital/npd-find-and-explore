# frozen_string_literal: true

require_relative 'sheet'

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
