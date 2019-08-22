# frozen_string_literal: true

module DataTable
  class Nccis < Tab
  private

    def tab_label
      'NCCIS'
    end

    def regex
      /^NCCIS/i
    end
  end
end
