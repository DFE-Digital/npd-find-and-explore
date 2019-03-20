# frozen_string_literal: true

require_relative 'sheet'

module DfEDataTables
  module Parsers
    class Absence < Sheet
      private

      def regex
        /Absence#{YEARS_REGEX}/
      end
    end
  end
end
