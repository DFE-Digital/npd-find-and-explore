# frozen_string_literal: true

require 'administrate/base_dashboard'

class DataElementDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    versions: Field::HasMany.with_options(class_name: 'PaperTrail::Version'),
    concept: Field::BelongsTo,
    id: Field::String.with_options(searchable: false),
    source_table_name: Field::String,
    source_attribute_name: Field::String,
    additional_attributes: Field::String.with_options(searchable: false),
    identifiability: Field::Number,
    sensitivity: Field::String,
    created_at: Field::DateTime.with_options(timezone: 'GB'),
    updated_at: Field::DateTime.with_options(timezone: 'GB'),
    source_old_attribute_name: Field::String,
    academic_year_collected_from: Field::Number,
    academic_year_collected_to: Field::Number,
    collection_terms: Field::String,
    values: Field::Text,
    description: Field::Text,
    npd_alias: Field::String,
    data_type: Field::String,
    educational_phase: Field::String,
    datasets: HasManySortedField.with_options(order: %i[name]),
    dataset: Field::String
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    dataset
    npd_alias
    concept
    datasets
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    npd_alias
    source_table_name
    source_attribute_name
    description
    concept
    datasets
    identifiability
    sensitivity
    source_old_attribute_name
    academic_year_collected_from
    academic_year_collected_to
    collection_terms
    values
    data_type
    educational_phase
    created_at
    updated_at
    additional_attributes
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    npd_alias
    source_table_name
    source_attribute_name
    identifiability
    sensitivity
    source_old_attribute_name
    academic_year_collected_from
    academic_year_collected_to
    collection_terms
    values
    description
    data_type
    educational_phase
    concept
    additional_attributes
  ].freeze

  # Overwrite this method to customize how data elements are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(data_element)
    "#{data_element.source_table_name}.#{data_element.source_attribute_name}"
  end
end
