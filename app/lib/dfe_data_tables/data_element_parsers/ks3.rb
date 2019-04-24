# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
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
