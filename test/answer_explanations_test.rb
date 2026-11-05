require "test_helper"

class AnswerExplanationsTest < ActiveSupport::TestCase
  setup { @original_host = EasyFlow.host_named(Alembic::FLOW_HOST) }

  teardown do
    @original_host.setting_explanations = nil
    EasyFlow.hosts[Alembic::FLOW_HOST.to_s] = @original_host
  end

  test "a question's answer weight is explained as the points scored, with any weight above zero making it right" do
    assert_match(/points.*above zero.*right answer/, explained("question", "answers", "weight"))
  end

  test "a multiple select answer weight is explained as one point for ticking exactly the right answers" do
    assert_match(/above zero.*one point.*every right answer and no others/, explained("multiple_select", "answers", "weight"))
  end

  private

  def explained(step_type, list, field, host: flow_host)
    palette_entry(step_type, host)["record_explanations"][list][field]
  end

  def palette_entry(step_type, host)
    EasyFlow::Canvas.new(EasyFlow::Document.new({}), host: host).to_h["palette"].find { |entry| entry["type"] == step_type }
  end

  def flow_host
    EasyFlow.host_named(Alembic::FLOW_HOST)
  end
end
