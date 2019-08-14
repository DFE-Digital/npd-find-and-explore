# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class Cla < Sheet
    private

      def regex
        /^CLA/i
      end
    end
  end
end
