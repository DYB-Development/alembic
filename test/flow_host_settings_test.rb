require "test_helper"

class FlowHostSettingsTest < ActiveSupport::TestCase
  setup do
    @original_options = Alembic::FLOW_HOST_SETTINGS.index_with { |name| Alembic.public_send(name) }
    @original_host = flow_host.dup
  end

  teardown do
    @original_options.each { |name, value| Alembic.public_send(:"#{name}=", value) }
    EasyFlow.hosts[Alembic::FLOW_HOST.to_s] = @original_host
  end

  test "step types a host limits stay limited after an alembic option is set" do
    flow_host.offers = %i[question]

    Alembic.owner_method = :current_customer

    assert_not flow_host.offers?(:checklist)
  end

  test "a back link a host set stays after an alembic option is set" do
    flow_host.back_link = { label: "Games", address: "/admin/games" }

    Alembic.owner_method = :current_customer

    assert_equal "Games", flow_host.back_link&.label
  end

  test "a publish note a host set stays after an alembic option is set" do
    flow_host.publish_note = "Players see this at once."

    Alembic.owner_method = :current_customer

    assert_equal "Players see this at once.", flow_host.publish_note
  end

  test "always showing insert buttons stays on after an alembic option is set" do
    flow_host.always_show_insert_buttons = true

    Alembic.owner_method = :current_customer

    assert flow_host.always_show_insert_buttons?
  end

  test "hiding step type codes stays on after an alembic option is set" do
    flow_host.hide_step_type_codes = true

    Alembic.owner_method = :current_customer

    assert flow_host.hide_step_type_codes?
  end

  test "finding flows across owners stays on after an alembic option is set" do
    flow_host.finds_flows_across_owners = true

    Alembic.owner_method = :current_customer

    assert flow_host.finds_flows_across_owners
  end

  test "a host's allowed answers stay after an alembic option is set" do
    flow_host.allowed_answers = ->(_step, answers) { answers.first(1) }

    Alembic.owner_method = :current_customer

    assert_equal [ "a" ], flow_host.answers_allowed(nil, [ "a", "b" ])
  end

  test "the layout given to alembic reaches its easy_flow host" do
    Alembic.layout = "mailer"

    assert_equal "mailer", flow_host.layout
  end

  test "the admin layout given to alembic reaches its easy_flow host" do
    Alembic.admin_layout = "mailer"

    assert_equal "mailer", flow_host.admin_layout
  end

  test "the admin authentication method given to alembic reaches its easy_flow host" do
    Alembic.admin_authentication_method = :require_admin

    assert_equal :require_admin, flow_host.admin_authentication_method
  end

  test "the visitor authorization method given to alembic reaches its easy_flow host" do
    Alembic.visitor_authorization_method = :visitor_permitted?

    assert_equal :visitor_permitted?, flow_host.visitor_authorization_method
  end

  test "the refusal method given to alembic reaches its easy_flow host" do
    Alembic.refusal_method = :refuse_visitor

    assert_equal :refuse_visitor, flow_host.refusal_method
  end

  private

  def flow_host
    EasyFlow.host_named(Alembic::FLOW_HOST)
  end
end
