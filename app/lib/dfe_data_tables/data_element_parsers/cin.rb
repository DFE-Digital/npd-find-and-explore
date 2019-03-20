# frozen_string_literal: true

require_relative 'sheet'

module DfEDataTables
  module DataElementParsers
    class Cin < Sheet
      private

      def regex
        /CIN#{YEARS_REGEX}/
      end

      def first_row_regex
        /(n_Census_CIN_Overall|n_Census_CIN_Child|n_Census_CIN_CPP|n_Census_CIN_Details|n_Census_CIN_Disabilities|n_Census_CIN_OpenCase|n_Census_CIN_ServiceProvision)/i
      end
    end
  end
end
