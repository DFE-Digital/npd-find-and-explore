# frozen_string_literal: true

class DfEDataTable < ApplicationRecord
  default_scope { order(created_at: :asc) }

  belongs_to :admin_user, inverse_of: :dfe_data_tables, optional: true

  has_one_attached :data_table
end
