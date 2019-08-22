# frozen_string_literal: true

module DataTable
  class PruCensus < Tab
  private

    def tab_label
      'PRU Census'
    end

    def regex
      /^(PRU_Census|PRU Census|PRUCensus)/i
    end
  end
end
