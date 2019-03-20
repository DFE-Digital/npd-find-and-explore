# frozen_string_literal: true

require_relative 'sheet'

module DfEDataTables
  module Parsers
    class Cla < Sheet
      private

      def regex
        /CLA#{YEARS_REGEX}/
      end
    end
  end
end
