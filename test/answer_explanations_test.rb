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

  test "setting an alembic option keeps what a host app explained" do
    flow_host.setting_explanations = { question: { "answers.weight" => "The host app's words." } }

    Alembic.owner_method = :current_customer

    assert_equal "The host app's words.", explained("question", "answers", "weight")
  ensure
    Alembic.owner_method = nil
  end

  test "a host declared again before the app is prepared still carries alembic's text" do
    EasyFlow.host(Alembic::FLOW_HOST)

    Rails.application.reloader.prepare!

    assert_match(/points/, explained("question", "answers", "weight"))
  end

  private

  def explained(step_type, list, field, host: flow_host)
    palette_entry(step_type, host)["record_explanations"][list][field]
  end

  def palette_entry(step_type, host)
    palette(host).find { |entry| entry["type"] == step_type }
  end

  def palette(host)
    EasyFlow::Canvas.new(EasyFlow::Document.new({}), host: host).to_h["palette"]
  end

  def flow_host
    EasyFlow.host_named(Alembic::FLOW_HOST)
  end
end
