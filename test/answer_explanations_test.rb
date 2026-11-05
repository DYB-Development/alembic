require "test_helper"

class AnswerExplanationsTest < ActiveSupport::TestCase
  ANSWERED_STEP_TYPES = %w[question multiple_select fill_in_the_blank].freeze

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

  test "a host app's own explanation replaces alembic's for that field" do
    flow_host.setting_explanations = { question: { "answers.weight" => "The host app's words." } }

    assert_equal "The host app's words.", explained("question", "answers", "weight")
  end

  test "a question answer's value is explained as what is saved and what shows when the label is blank or values are shown" do
    assert_match(/saved.*label is blank.*shows answer values/, explained("question", "answers", "value"))
  end

  test "a question answer's label is explained as the text a player sees in place of the value" do
    assert_match(/player sees.*in place of its value/, explained("question", "answers", "label"))
  end

  test "a question answer's hint is explained as a smaller line a player sees under the answer" do
    assert_match(/smaller line a player sees under/, explained("question", "answers", "hint"))
  end

  test "a question answer's info is explained as saved detail that alembic's question page does not show" do
    assert_match(/saved with this answer.*does not show/, explained("question", "answers", "info"))
  end

  test "a multiple select answer's value is explained as what is saved and what shows when the label is blank" do
    assert_match(/saved when a player ticks.*label is blank/, explained("multiple_select", "answers", "value"))
  end

  test "a multiple select answer's label is explained as the text a player sees in place of the value" do
    assert_match(/player sees.*in place of its value/, explained("multiple_select", "answers", "label"))
  end

  test "a fill in the blank accepted answer is explained as what a typed answer must match to score one point" do
    assert_match(/matches this text.*capitals.*one point/, explained("fill_in_the_blank", "accepted_answers", "value"))
  end

  test "every other step type offers the same palette entry on alembic's host as on a plain host" do
    assert_equal other_entries(EasyFlow::Host.new("plain")), other_entries(flow_host)
  end

  test "another easy_flow host gets none of alembic's explanations" do
    assert_nil explained("question", "answers", "weight", host: EasyFlow::Host.new("console"))
  end

  test "a host app setting one explanation keeps alembic's text on the other fields" do
    flow_host.setting_explanations = { question: { "answers.weight" => "The host app's words." } }

    assert_match(/in place of its value/, explained("question", "answers", "label"))
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

  def other_entries(host)
    palette(host).reject { |entry| ANSWERED_STEP_TYPES.include?(entry["type"]) }
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
