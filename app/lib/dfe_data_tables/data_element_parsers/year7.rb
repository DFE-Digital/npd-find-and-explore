# frozen_string_literal: true

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
