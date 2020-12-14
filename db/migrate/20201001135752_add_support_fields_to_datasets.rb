# frozen_string_literal: true

class AddSupportFieldsToDatasets < ActiveRecord::Migration[5.2]
  def up
    add_column :datasets, :tab_regex, :string
    add_column :datasets, :headers_regex, :string
    add_column :datasets, :first_row_regex, :string

    Rails.configuration.datasets.each do |dataset|
      obj = Dataset.find_or_create_by!(tab_name: dataset['tab_name'])
      obj.update!(name: dataset['name'], description: dataset['description'],
                  tab_regex: dataset['tab_regex'],
                  headers_regex: dataset['headers_regex'],
                  first_row_regex: dataset['first_row_regex'])
    end

    remove_column :datasets, :tab_type
  end

  def down
    add_column :datasets, :tab_type, :string
    Rails.configuration.datasets.each do |dataset|
      obj = Dataset.find_or_create_by!(tab_name: dataset['tab_name'])
      obj.update!(name: dataset['name'], description: dataset['description'],
                  tab_name: dataset['tab_name'], tab_type: dataset['type'])
    end
    remove_column :datasets, :tab_regex
    remove_column :datasets, :headers_regex
    remove_column :datasets, :first_row_regex
  end
end
