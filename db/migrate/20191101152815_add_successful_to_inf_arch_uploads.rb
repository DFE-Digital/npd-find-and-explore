# frozen_string_literal: true

class AddSuccessfulToInfArchUploads < ActiveRecord::Migration[5.2]
  def change
    add_column :inf_arch_uploads, :successful, :boolean, default: nil
    InfArch::Upload.update_all(successful: true)
  end
end
