require "json"
require "alembic/version"
require "alembic/engine"

module Alembic
  NotPublished = EasyFlow::NotPublished
  NotPermitted = EasyFlow::NotPermitted
  OutOfService = EasyFlow::OutOfService
  Withdrawn = EasyFlow::Withdrawn

  SHARED_WITH_EASY_FLOW = %i[layout base_controller admin_layout
                             admin_authentication_method visitor_authorization_method refusal_method].freeze

  class << self
    attr_accessor :lead_partial
    attr_reader :admin_authentication_method, :visitor_authorization_method, :refusal_method

    SHARED_WITH_EASY_FLOW.each do |name|
      define_method(:"#{name}=") do |value|
        instance_variable_set(:"@#{name}", value)
        EasyFlow.public_send(:"#{name}=", value)
      end
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
