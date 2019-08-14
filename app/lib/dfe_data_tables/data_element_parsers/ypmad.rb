# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class Ypmad < Sheet
    private

      def regex
        /^YPMAD/i
      end

      def first_row_regex
        /(Chronological Indicators|Snapshot Indicators)/
      end
    end
  end
end
