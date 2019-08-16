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
  end
end
