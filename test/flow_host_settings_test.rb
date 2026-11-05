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

  private

  def flow_host
    EasyFlow.host_named(Alembic::FLOW_HOST)
  end
end
