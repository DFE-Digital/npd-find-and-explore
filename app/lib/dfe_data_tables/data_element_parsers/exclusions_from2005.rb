# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class ExclusionsFrom2005 < Sheet
    private

      def regex
        /^Exclusions_05-06/i
      end

      def first_row_regex
        /(Per Pupil|Following variables repeated)/i
      end
    end
  end
end
