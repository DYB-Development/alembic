require "json"
require "alembic/version"
require "alembic/engine"

module Alembic
  NotPublished = EasyFlow::NotPublished
  NotPermitted = EasyFlow::NotPermitted
  OutOfService = EasyFlow::OutOfService
  Withdrawn = EasyFlow::Withdrawn

  FLOW_HOST = :alembic
  FLOW_HOST_SETTINGS = %i[layout admin_layout admin_authentication_method
                          visitor_authorization_method refusal_method].freeze

  class << self
    attr_accessor :lead_partial
    attr_reader :admin_authentication_method, :visitor_authorization_method, :refusal_method

    FLOW_HOST_SETTINGS.each do |name|
      define_method(:"#{name}=") do |value|
        instance_variable_set(:"@#{name}", value)
        set_up_flow_host
      end
    end

    def set_up_flow_host
      EasyFlow.host(FLOW_HOST) do |host|
        FLOW_HOST_SETTINGS.each { |name| host.public_send(:"#{name}=", public_send(name)) }
      end
    end

    def base_controller=(value)
      @base_controller = value
      EasyFlow.base_controller = value
    end

    # The host app sets this to render the engine inside its own layout
    # (e.g. "marketing"). Defaults to the engine's own layout.
    def layout
      @layout || "alembic/application"
    end

    # The host app sets this (e.g. "ApplicationController") so the engine's
    # controllers inherit the host's helpers, layout chrome, and concerns.
    # Defaults to a plain controller.
    def base_controller
      @base_controller || "ActionController::Base"
    end

    # The host app sets this to render the builder inside its own admin
    # chrome. Defaults to the conventional application layout.
    def admin_layout
      @admin_layout || "application"
    end
  end

  set_up_flow_host
end
