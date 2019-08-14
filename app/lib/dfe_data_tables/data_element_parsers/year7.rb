# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class Year7 < Sheet
    private

      def regex
        /^(Year_7|Year 7|Year7)/i
      end
    end
  end
end
