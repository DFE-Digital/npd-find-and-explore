# frozen_string_literal: true

module DataTable
  class Ks5 < Tab
  private

    def tab_label
      'KS5'
    end

    def regex
      /^KS5/i
    end

    def first_row_regex
      /(KS5 Student Table|KS5 Exam Table)/i
    end
  end
end
