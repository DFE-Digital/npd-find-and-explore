# frozen_string_literal: true

require_relative 'sheet'

module DfEDataTables
  module DataElementParsers
    class Year7 < Sheet
    private

      def regex
        /Year_7#{YEARS_REGEX}/
      end
    end
  end
end
