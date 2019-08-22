# frozen_string_literal: true

module DataTable
  class ExclusionsUpTo2005 < Tab
  private

    def tab_label
      'Exclusions Up To 2005'
    end

    def regex
      /^Exclusions_\d{2}-\d{2}_to_04-05/i
    end
  end
end
