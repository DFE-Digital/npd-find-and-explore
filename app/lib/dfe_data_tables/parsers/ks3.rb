# frozen_string_literal: true

require_relative 'sheet'

module DfEDataTables
  module Parsers
    class Ks3 < Sheet
      private

      def regex
        /KS3#{YEARS_REGEX}/
      end

      def first_row_regex
        /(KS3 Candidate|KS3 Indicators|KS3 Result Table)/i
      end
    end
  end
end
