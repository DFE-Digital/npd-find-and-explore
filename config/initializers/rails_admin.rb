# frozen_string_literal: true

RailsAdmin.config do |config|
  config.main_app_name = ['NPD Find & Explore']
  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

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
    end
  end
end
