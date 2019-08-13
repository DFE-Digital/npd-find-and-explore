# frozen_string_literal: true

module DfEDataTables
  EXCEL_CONTENT_TYPE = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  UPLOAD_CONTENT_TYPES = ['application/octet-stream', EXCEL_CONTENT_TYPE].freeze
  EXCEL_EXTENSION = '.xlsx'

  def self.check_content_type(upload)
    File.extname(upload.original_filename) == EXCEL_EXTENSION ||
      DfEDataTables::UPLOAD_CONTENT_TYPES.include?(upload.content_type)
  end
end
