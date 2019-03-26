# frozen_string_literal: true

require_relative 'sheet'

module DfEDataTables
  module DataElementParsers
    class Ks4 < Sheet
    private

      def regex
        /KS4#{YEARS_REGEX}/
      end

      def first_row_regex
        /(KS4 Pupil Table|KS4 Exam Table)/i
      end
    end
  end
end
