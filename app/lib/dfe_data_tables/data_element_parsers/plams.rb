# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class Plams < Sheet
    private

      def regex
        /^PLAMS/i
      end
    end
  end
end
