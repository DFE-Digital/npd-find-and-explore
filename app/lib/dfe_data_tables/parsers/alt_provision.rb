# frozen_string_literal: true

require_relative 'sheet'

module DfEDataTables
  module Parsers
    class AltProvision < Sheet
      private

      def regex
        /Alt_Provision#{YEARS_REGEX}/
      end
    end
  end
end
