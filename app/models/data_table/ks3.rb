# frozen_string_literal: true

module DataTable
  class Ks3 < Tab
  private

    def tab_label
      'KS3'
    end

    def regex
      /^KS3/i
    end

    def first_row_regex
      /(KS3 Candidate|KS3 Indicators|KS3 Result Table)/i
    end
  end
end
