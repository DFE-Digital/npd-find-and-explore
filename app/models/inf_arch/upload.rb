# frozen_string_literal: true

module InfArch
  class Upload < ApplicationRecord
    include ProcessCategories

    belongs_to :admin_user, inverse_of: :inf_arch_uploads, optional: true
    has_many :inf_arch_tabs,
             class_name: 'InfArch::Tab', foreign_key: :inf_arch_upload_id,
             inverse_of: :inf_arch_upload, dependent: :destroy

    has_one_attached :data_table

    attr_accessor :workbook

    def initialize(attr)
      @workbook = Roo::Spreadsheet.open(attr.delete(:data_table))
      super(attr)
    end
  end
end
