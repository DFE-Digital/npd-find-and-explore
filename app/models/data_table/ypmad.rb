# frozen_string_literal: true

module DataTable
  class Ypmad < Tab
  private

    def tab_label
      'YPMAD'
    end

    def regex
      /^YPMAD/i
    end

    def first_row_regex
      /(Chronological Indicators|Snapshot Indicators)/
    end
  end
end
