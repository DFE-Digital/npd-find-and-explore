# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class Eyfsp < Sheet
    private

      def regex
        /^EYFSP/i
      end
    end
  end
end
