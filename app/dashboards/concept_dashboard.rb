# frozen_string_literal: true

require 'administrate/base_dashboard'

class ConceptDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::String.with_options(searchable: false),
    name: Field::String,
    category: BreadcrumbField.with_options(order: :name),
    data_elements: HasManySortedField.with_options(order: %i[source_table_name source_attribute_name]),
    versions: Field::HasMany.with_options(class_name: 'PaperTrail::Version'),
    created_at: Field::DateTime.with_options(timezone: 'GB'),
    updated_at: Field::DateTime.with_options(timezone: 'GB')
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    name
    category
    data_elements
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    name
    category
    data_elements
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    name
    category
    data_elements
  ].freeze

  # Overwrite this method to customize how concepts are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(concept)
    concept.name
  end
end
