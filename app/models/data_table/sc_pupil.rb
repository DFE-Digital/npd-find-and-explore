# frozen_string_literal: true

module DataTable
  class ScPupil < Tab
  private

    def tab_label
      'SC Pupil'
    end

    def regex
      /^(SC_Pupil|SC Pupil|SCPupil)/i
    end
  end
end
