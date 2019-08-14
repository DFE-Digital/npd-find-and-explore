# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class Ks5 < Sheet
    private

      def regex
        /^KS5/i
      end

      def first_row_regex
        /(KS5 Student Table|KS5 Exam Table)/i
      end
    end
  end
end
