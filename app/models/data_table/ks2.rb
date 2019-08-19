# frozen_string_literal: true

module DataTable
  class Ks2 < Tab
  private

    def tab_label
      'KS2'
    end

    def regex
      /^KS2/i
    end

    def first_row_regex
      /(KS2 Pupil table|KS2 Exam table)/i
    end
  end
end
