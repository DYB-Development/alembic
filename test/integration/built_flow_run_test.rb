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

    test "with no finish link set, the finish page links only to Start over" do
      run = started_run
      patch alembic.run_path(run), params: { answers: { budget: "low" } }

      get alembic.run_path(run)

      assert_equal [ "Start over" ], css_select("a").map { |link| link.text.strip }
    end

    test "a host app sets where Start over leads from a run" do
      Alembic.start_over_address = ->(flow) { "/play/#{flow.public_code}" }

      get alembic.run_path(started_run)

      assert_select "a[href=?]", "/play/#{built.public_code}", text: /Start over/
    ensure
      Alembic.start_over_address = nil
    end

    test "a host app adds a link to the finish page of a flow built in the builder" do
      Alembic.finish_link = ->(flow) { { label: "See the scoreboard", url: "/play/#{flow.public_code}/scoreboard" } }
      run = started_run
      patch alembic.run_path(run), params: { answers: { budget: "low" } }

      get alembic.run_path(run)

      assert_select "a[href=?]", "/play/#{built.public_code}/scoreboard", text: "See the scoreboard"
    ensure
      Alembic.finish_link = nil
    end

    test "Start over from a run opens the flow in a host app that finds flows by public code across owners" do
      EasyFlow.host_named(Alembic::FLOW_HOST).finds_flows_across_owners = true
      get alembic.run_path(EasyFlow::Run.start(built))

      get css_select("a").find { |link| link.text.include?("Start over") }["href"]

      assert_response :success
    ensure
      EasyFlow.host_named(Alembic::FLOW_HOST).finds_flows_across_owners = false
    end

    test "a flow built in the builder shows its questions on one page" do
      built.update!(persists: :unsaved)
      Flow::Summaries.new(built).ask_on_one_page(true)

      get alembic.flow_step_path(built.slug)

      assert_select "form[action=?]", alembic.flow_step_path(built.slug)
    end

    test "a flow built in the builder that keeps no run asks its first question" do
      built.update!(persists: :unsaved)

      get alembic.flow_step_path(built.slug)

      assert_select "form[action=?]", alembic.flow_step_path(built.slug)
    end
  end
end
