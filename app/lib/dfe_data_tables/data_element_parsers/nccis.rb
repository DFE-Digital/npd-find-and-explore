# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class Nccis < Sheet
    private

      def regex
        /^NCCIS/i
      end
    end
  end
end
