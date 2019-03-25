# frozen_string_literal: true

require_relative 'sheet'

module DfEDataTables
  module DataElementParsers
    class Ypmad < Sheet
      private

      def regex
        /YPMAD \d{2}-\d{2}/
      end

      def first_row_regex
        /(Chronological Indicators|Snapshot Indicators)/
      end
    end
  end
end
