# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class AltProvision < Sheet
    private

      def regex
        /^(Alt_Provision|Alt Provision|AltProvision)/i
      end
    end
  end
end
