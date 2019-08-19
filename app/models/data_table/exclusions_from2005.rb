# frozen_string_literal: true

module DataTable
  class ExclusionsFrom2005 < Tab
  private

    def tab_label
      'Exclusions From 2005'
    end

    def regex
      /^Exclusions_05-06/i
    end

    def first_row_regex
      /(Per Pupil|Following variables repeated)/i
    end
  end
end
