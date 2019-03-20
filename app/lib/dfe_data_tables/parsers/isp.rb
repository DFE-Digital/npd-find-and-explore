# frozen_string_literal: true

require_relative 'sheet'

module DfEDataTables
  module Parsers
    class Isp < Sheet
      private

      def regex
        /ISP#{YEARS_REGEX}/
      end

      def first_row_regex
        /(Placement\/Student|Funding|Support)/
      end
    end
  end
end
