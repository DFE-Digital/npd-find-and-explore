# frozen_string_literal: true

require_relative 'sheet'

module DfEDataTables
  module DataElementParsers
    class Ks2 < Sheet
    private

      def regex
        /KS2#{YEARS_REGEX}/
      end

      def first_row_regex
        /(KS2 Pupil table|KS2 Exam table)/i
      end
    end
  end
end
