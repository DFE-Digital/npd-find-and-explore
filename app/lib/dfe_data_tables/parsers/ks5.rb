# frozen_string_literal: true

require_relative 'sheet'

module DfEDataTables
  module Parsers
    class Ks5 < Sheet
      private

      def regex
        /KS5#{YEARS_REGEX}/
      end

      def first_row_regex
        /(KS5 Student Table|KS5 Exam Table)/i
      end
    end
  end
end
