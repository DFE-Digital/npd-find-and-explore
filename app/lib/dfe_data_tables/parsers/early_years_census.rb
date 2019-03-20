# frozen_string_literal: true

require_relative 'sheet'

module DfEDataTables
  module Parsers
    class EarlyYearsCensus < Sheet
      private

      def regex
        /EarlyYearsCensus#{YEARS_REGEX}/
      end
    end
  end
end
