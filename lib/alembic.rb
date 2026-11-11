require "json"
require "question_kit"
require "alembic/version"
require "alembic/engine"
require "alembic/answer_explanations"

module Alembic
  NotPublished = EasyFlow::NotPublished
  NotPermitted = EasyFlow::NotPermitted
  OutOfService = EasyFlow::OutOfService
  Withdrawn = EasyFlow::Withdrawn

  FLOW_HOST = :alembic
  FLOW_HOST_SETTINGS = %i[layout admin_layout admin_authentication_method
                          visitor_authorization_method refusal_method owner_method].freeze

  class << self
    attr_accessor :lead_address, :lead_fields_partial, :lead_note, :start_over_address, :finish_link, :marks_right_answers
    attr_reader :admin_authentication_method, :visitor_authorization_method, :refusal_method, :owner_method
    attr_writer :finish_title, :finish_subtitle, :finish_answers_heading

    def finish_title
      @finish_title || "That's everything"
    end

    def finish_subtitle
      @finish_subtitle || "Thanks — here's what you told us"
    end

    def finish_answers_heading
      @finish_answers_heading || "What you told us"
    end

    FLOW_HOST_SETTINGS.each do |name|
      define_method(:"#{name}=") do |value|
        instance_variable_set(:"@#{name}", value)
        set_up_flow_host
      end
    end

    def set_up_flow_host
      host = explain_answer_fields
      FLOW_HOST_SETTINGS.each { |name| host.public_send(:"#{name}=", public_send(name)) }
    end

    def explain_answer_fields
      flow_host.tap { QuestionKit.flow_host = FLOW_HOST }
    end

    def lead_partial=(_partial)
      warn "Alembic.lead_partial no longer exists and draws nothing. Set Alembic.lead_address to where the lead block posts."
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

    private

    def flow_host
      host = EasyFlow.host_named(FLOW_HOST)
      host.set_up? ? host : EasyFlow.host(FLOW_HOST)
    end
  end

  set_up_flow_host
end
