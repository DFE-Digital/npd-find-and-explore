# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class Ks4 < Sheet
    private

      def regex
        /^KS4/i
      end

      def first_row_regex
        /(KS4 Pupil Table|KS4 Exam Table)/i
      end
    end
  end
end
