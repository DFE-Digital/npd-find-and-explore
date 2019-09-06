# frozen_string_literal: true

# set / to the service start page
HighVoltage.configure do |config|
  config.route_drawer = HighVoltage::RouteDrawers::Root
end
