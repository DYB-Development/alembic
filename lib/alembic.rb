require "json"
require "alembic/version"
require "alembic/engine"

module Alembic
  NotPublished = EasyFlow::NotPublished
  NotPermitted = EasyFlow::NotPermitted
  OutOfService = EasyFlow::OutOfService
  Withdrawn = EasyFlow::Withdrawn

  class << self
    attr_accessor :lead_partial
    attr_writer :layout, :admin_layout
    attr_accessor :admin_authentication_method, :visitor_authorization_method, :refusal_method

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
end
