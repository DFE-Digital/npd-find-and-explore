# frozen_string_literal: true

module DataTable
  class Cin < Tab
  private

    def tab_label
      'CIN'
    end

    def regex
      /^CIN/i
    end

    def first_row_regex
      /(n_Census_CIN_Overall|n_Census_CIN_Child|n_Census_CIN_CPP|n_Census_CIN_Details|n_Census_CIN_Disabilities|n_Census_CIN_OpenCase|n_Census_CIN_ServiceProvision)/i
    end
  end
end
