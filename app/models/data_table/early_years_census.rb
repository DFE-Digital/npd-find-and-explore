# frozen_string_literal: true

module DataTable
  class EarlyYearsCensus < Tab
  private

    def tab_label
      'Early Years Census'
    end

    def regex
      /^(Early_Years_Census|Early Years Census|EarlyYearsCensus)/i
    end
  end
end
