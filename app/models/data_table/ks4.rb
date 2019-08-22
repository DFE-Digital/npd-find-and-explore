# frozen_string_literal: true

module DataTable
  class Ks4 < Tab
  private

    def tab_label
      'KS4'
    end

    def regex
      /^KS4/i
    end

    def first_row_regex
      /(KS4 Pupil Table|KS4 Exam Table)/i
    end
  end
end
