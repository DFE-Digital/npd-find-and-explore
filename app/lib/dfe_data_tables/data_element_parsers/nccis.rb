# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class Nccis < Sheet
    private

      def regex
        /NCCIS#{YEARS_REGEX}/
      end
    end
  end
end
