require "test_helper"

module Alembic
  class BuiltFlowRunTest < ActionDispatch::IntegrationTest
    def built
      @built ||= EasyFlow::Definition.create!(host: "alembic", slug: "built", persists: :each_step).tap do |flow|
        flow.record_definition(flowing(
          "entry" => "budget",
          "nodes" => [ { "id" => "budget", "type" => "question", "text" => "Budget?",
                         "options" => [ { "value" => "low", "label" => "Modest", "weight" => 2 } ] } ]
        ))
        flow.publish
      end
    end

    def started_run
      post alembic.flow_runs_path(built.slug)
      EasyFlow::Run.last
    end

    test "a run of a flow built in the builder shows its question page" do
      get alembic.run_path(started_run)

      assert_response :success
    end

    test "a finished run of a flow built in the builder shows its finish page" do
      run = started_run
      patch alembic.run_path(run), params: { answers: { budget: "low" } }

      get alembic.run_path(run)

      assert_select "[data-answer=budget]"
    end

    test "a host app sets where Start over leads from a run" do
      Alembic.start_over_address = ->(flow) { "/play/#{flow.public_code}" }

      get alembic.run_path(started_run)

      assert_select "a[href=?]", "/play/#{built.public_code}", text: /Start over/
    ensure
      Alembic.start_over_address = nil
    end

    test "Start over from a run opens the flow in a host app that finds flows by public code across owners" do
      EasyFlow.host_named(Alembic::FLOW_HOST).finds_flows_across_owners = true
      get alembic.run_path(EasyFlow::Run.start(built))

      get css_select("a").find { |link| link.text.include?("Start over") }["href"]

      assert_response :success
    ensure
      EasyFlow.host_named(Alembic::FLOW_HOST).finds_flows_across_owners = false
    end
  end
end
