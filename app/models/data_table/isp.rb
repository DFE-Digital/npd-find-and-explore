# frozen_string_literal: true

module DataTable
  class Isp < Tab
  private

    def tab_label
      'ISP'
    end

    def regex
      /^ISP/i
    end

    def first_row_regex
      %r{(Placement/Student|Funding|Support)}
    end
  end
end
