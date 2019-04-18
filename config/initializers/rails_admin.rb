# frozen_string_literal: true

require Rails.root.join('app', 'lib', 'dfe_data_tables', 'data_elements_loader')

RailsAdmin.config do |config|
  config.main_app_name = ['NPD Find & Explore']
  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :admin_user
  end
  config.current_user_method(&:current_admin_user)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  config.audit_with :paper_trail, 'AdminUser', 'PaperTrail::Version'

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  config.show_gravatar = false

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    export
    show
    show_in_app
    new do
      except %w[DataElement]
    end
    bulk_delete do
      except %w[DataElement]
    end
    edit do
      except %w[DataElement]
    end
    delete do
      except %w[DataElement]
    end

    root :import do
      http_methods %i[get]
    end

    root :do_import do
      http_methods %i[post]
      visible false

      controller do
        proc do
          DfEDataTables::DataElementsLoader.new(params['file-upload'].tempfile)

          render 'import_success', format: :js, layout: false
        rescue StandardError => error
          Rails.logger.error(error)
          render 'import_failure', format: :js, layout: false
        end
      end
    end

    ## With an audit adapter, you can add:
    # history_index
    # history_show

    # Nested trees with Ancestry gem
    nestable do
      visible do
        %w[Category].include? bindings[:abstract_model].model_name
      end
    end
  end

  config.model Category do
    nestable_tree(
      position_field: :position,
      max_depth: 10
    )

    base do
      # virtual field needs to be configured explicitly, otherwise RailsAdmin errors...
      configure :name
      configure :description

      field :name
      field :description
      field :concepts do
        inverse_of :category
      end
    end
  end

  config.model Concept do
    base do
      # virtual field needs to be configured explicitly, otherwise RailsAdmin errors...
      configure :name
      configure :description

      field :name
      field :description
      field :category do
        inverse_of :concepts
      end
      field :data_elements do
        inverse_of :concept
      end
    end
  end

  config.model DataElement do
    base do
      # virtual field needs to be configured explicitly, otherwise RailsAdmin errors...
      configure :description

      field :source_table_name
      field :source_attribute_name
      field :source_old_attribute_name
      field :identifiability
      field :sensitivity
      field :academic_year_collected_from
      field :academic_year_collected_to
      field :collection_terms
      field :values
      field :concept do
        inverse_of :data_elements
      end
    end
  end
end
