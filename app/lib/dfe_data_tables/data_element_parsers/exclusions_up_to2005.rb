# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class ExclusionsUpTo2005 < Sheet
    private

      def regex
        /Exclusions_\d{2}-\d{2}_to_04-05/
      end
    end
  end
end
