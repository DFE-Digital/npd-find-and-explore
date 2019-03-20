# frozen_string_literal: true

require_relative 'sheet'

module DfEDataTables
  module Parsers
    class Eyfsp < Sheet
      private

      def regex
        /EYFSP#{YEARS_REGEX}/
      end
    end
  end
end
