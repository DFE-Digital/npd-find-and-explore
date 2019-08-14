# frozen_string_literal: true

module DfEDataTables
  module DataElementParsers
    class ScPupil < Sheet
    private

      def regex
        /^(SC_Pupil|SC Pupil|SCPupil)/i
      end
    end
  end
end
