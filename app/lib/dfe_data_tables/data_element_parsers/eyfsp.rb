# frozen_string_literal: true

require_relative 'sheet'

module DfEDataTables
  module DataElementParsers
    class Eyfsp < Sheet
      private

      def regex
        /EYFSP#{YEARS_REGEX}/
      end
    end
  end
end
