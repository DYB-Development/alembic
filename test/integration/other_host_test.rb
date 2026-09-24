require "test_helper"

module Alembic
  class OtherHostTest < ActionDispatch::IntegrationTest
    def console_flow
      @console_flow ||= EasyFlow::Definition.create!(host: "console", slug: "console-setup", title: "Console setup").tap do |flow|
        flow.record_definition(flowing("entry" => "ask",
          "nodes" => [ { "id" => "ask", "type" => "question", "text" => "Ready?", "options" => [ "yes" ] } ]))
        flow.publish
      end
    end

    test "alembic's visitor pages do not find a flow of another host" do
      get alembic.flow_path(console_flow.slug)

      assert_response :not_found
    end

    test "alembic's visitor pages do not open a run of another host's flow" do
      get alembic.run_path(EasyFlow::Run.start(console_flow))

      assert_response :not_found
    end

    test "alembic's management pages do not list a flow of another host" do
      console_flow

      get easy_flow.manage_flows_path

      assert_select "a", text: "Console setup", count: 0
    end

    test "alembic's management pages do not open a flow of another host" do
      get easy_flow.manage_flow_path(console_flow)

      assert_response :not_found
    end

    test "alembic's details editor does not open a flow of another host" do
      get easy_flow.edit_manage_flow_path(console_flow)

      assert_response :not_found
    end

    test "alembic's details editor does not save a summary onto a flow of another host" do
      patch easy_flow.manage_flow_path(console_flow), params: { flow: { summary: "Taken over" } }

      assert_nil Flow::Summaries.new(console_flow).text
    end

    test "alembic's previews do not open a flow of another host" do
      get alembic.manage_flow_preview_path(console_flow)

      assert_response :not_found
    end

    test "a flow created on alembic's management pages belongs to the alembic host" do
      post easy_flow.manage_flows_path, params: { flow: { slug: "made-here", kind: "guide" } }

      assert_equal "alembic", EasyFlow::Definition.find_by!(slug: "made-here").host
    end
  end
end
