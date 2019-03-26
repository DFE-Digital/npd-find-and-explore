# frozen_string_literal: true

require_relative 'sheet'

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
