# frozen_string_literal: true

require_relative 'sheet'

module DfEDataTables
  module Parsers
    class Nccis < Sheet
      private

      def regex
        /NCCIS#{YEARS_REGEX}/
      end
    end
  end
end
