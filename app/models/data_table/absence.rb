# frozen_string_literal: true

module DataTable
  class Absence < Tab
  private

    def tab_label
      'Absence'
    end

    def regex
      /^Absence/i
    end
  end
end
