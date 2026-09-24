require "test_helper"

module Alembic
  class FlowAdminTest < ActionDispatch::IntegrationTest
    test "the flow builder is served under alembic's address" do
      get "/alembic/manage/flows"

      assert_includes response.body, "Business Blind-Spot Scorecard"
    end

    test "the flow builder links each flow under alembic's address" do
      get easy_flow.manage_flows_path

      assert_select "a[href=?]", "/alembic/manage/flows/#{easy_flow_definitions(:business_scorecard).id}"
    end

    test "the flow builder creates a flow" do
      assert_difference -> { EasyFlow::Definition.count } do
        post easy_flow.manage_flows_path, params: { flow: { slug: "brand-new" } }
      end
    end

    test "the canvas is drawn from alembic's address" do
      flow = easy_flow_definitions(:business_scorecard)

      get easy_flow.manage_flow_path(flow)

      drawn = JSON.parse(css_select("[data-flow-canvas]").first["data-props"])
      assert_equal "/alembic/manage/flows/#{flow.id}/canvas", drawn["base"]
    end

    test "the details editor offers the flow's summary for editing" do
      flow = easy_flow_definitions(:business_scorecard)
      Flow::Summaries.new(flow).describe("What this asks about")

      get easy_flow.edit_manage_flow_path(flow)

      assert_select "textarea[name=?]", "flow[summary]", text: "What this asks about"
    end

    test "saving the details stores the flow's summary" do
      flow = easy_flow_definitions(:business_scorecard)

      patch easy_flow.manage_flow_path(flow), params: { flow: { summary: "New summary" } }

      assert_equal "New summary", Flow::Summaries.new(flow).text
    end
  end
end
