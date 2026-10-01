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

    test "the details editor labels its fields with the look's label style" do
      get easy_flow.edit_manage_flow_path(easy_flow_definitions(:business_scorecard))

      assert_select "label.ks-label", 3
    end

    test "the details editor draws its back link in the look's link colour" do
      get easy_flow.edit_manage_flow_path(easy_flow_definitions(:business_scorecard))

      assert_select "a[class~=?]", "text-(color:--ks-color-link)", text: /Back to the flow/
    end

    test "saving the details stores the flow's summary" do
      flow = easy_flow_definitions(:business_scorecard)

      patch easy_flow.manage_flow_path(flow), params: { flow: { summary: "New summary" } }

      assert_equal "New summary", Flow::Summaries.new(flow).text
    end

    test "the details editor offers each published page to finish on" do
      Page.create!(name: "Result").publish

      get easy_flow.edit_manage_flow_path(easy_flow_definitions(:business_scorecard))

      assert_select "select[name=?] option", "flow[summary_page_id]", text: "Result"
    end

    test "the details editor does not offer a page that was never published" do
      Page.create!(name: "Draft")

      get easy_flow.edit_manage_flow_path(easy_flow_definitions(:business_scorecard))

      assert_select "select[name=?] option", "flow[summary_page_id]", text: "Draft", count: 0
    end

    test "the details editor offers to show each answer's value beside its label" do
      get easy_flow.edit_manage_flow_path(easy_flow_definitions(:business_scorecard))

      assert_select "input[type=checkbox][name=?]", "flow[shows_answer_values]"
    end

    test "saving the details stores that the flow shows each answer's value" do
      flow = easy_flow_definitions(:business_scorecard)

      patch easy_flow.manage_flow_path(flow), params: { flow: { shows_answer_values: "1" } }

      assert Flow::Summaries.new(flow).shows_answer_values?
    end

    test "saving the details puts a flow with no branching on one page" do
      flow = straight_flow

      patch easy_flow.manage_flow_path(flow), params: { flow: { asks_on_one_page: "1" } }

      assert Flow::Summaries.new(flow).asks_on_one_page?
    end

    test "saving the details keeps a flow that branches off one page" do
      flow = branching_flow

      patch easy_flow.manage_flow_path(flow), params: { flow: { asks_on_one_page: "1" } }

      assert_not Flow::Summaries.new(flow).asks_on_one_page?
    end

    test "the details editor offers to ask a flow with no branching on one page" do
      get easy_flow.edit_manage_flow_path(straight_flow)

      assert_select "input[type=checkbox][name=?]:not([disabled])", "flow[asks_on_one_page]"
    end

    test "the details editor does not let a flow that branches go on one page" do
      get easy_flow.edit_manage_flow_path(branching_flow)

      assert_select "input[type=checkbox][name=?][disabled]", "flow[asks_on_one_page]"
    end

    test "the details editor offers each published page to start on" do
      Page.create!(name: "Welcome").publish

      get easy_flow.edit_manage_flow_path(easy_flow_definitions(:business_scorecard))

      assert_select "select[name=?] option", "flow[intro_page_id]", text: "Welcome"
    end

    test "the details editor links to a preview of the flow's intro page" do
      flow = straight_flow

      get easy_flow.edit_manage_flow_path(flow)

      assert_select "a[href=?]", alembic.manage_flow_preview_path(flow)
    end

    test "the details editor links to a preview of the flow's summary page with sample answers" do
      flow = straight_flow

      get easy_flow.edit_manage_flow_path(flow)

      assert_select "a[href=?]", alembic.step_manage_flow_preview_path(flow, answers: { "a" => "y", "b" => "y" })
    end

    test "the details editor offers each output's label for editing" do
      flow = straight_flow
      Flow::Summaries.new(flow).record("outputs" => [ { "id" => "share", "type" => "percentage", "label" => "Captured" } ])

      get easy_flow.edit_manage_flow_path(flow)

      assert_select "input[name=?][value=?]", "flow[outputs][0][label]", "Captured"
    end

    test "saving the details records the outputs as a new summary version" do
      flow = straight_flow
      Flow::Summaries.new(flow).record("outputs" => [ { "id" => "share", "type" => "percentage", "label" => "Captured" } ])

      patch easy_flow.manage_flow_path(flow), params: { flow: { outputs: { "0" => { id: "share", type: "percentage", label: "Measured" } } } }

      assert_equal [ 2, "Measured" ], Flow::Summaries.new(flow).current_version.then { |version| [ version.number, version.summary["outputs"].first["label"] ] }
    end

    test "the details editor offers each band's description for editing" do
      flow = straight_flow
      Flow::Summaries.new(flow).record("outputs" => [ { "id" => "band", "type" => "band", "of" => "share",
        "bands" => [ { "ceiling" => 40, "name" => "Low", "description" => "Room to grow." } ] } ])

      get easy_flow.edit_manage_flow_path(flow)

      assert_select "input[name=?][value=?]", "flow[outputs][0][bands][0][description]", "Room to grow."
    end

    test "saving the details stores the page the flow starts on" do
      flow = easy_flow_definitions(:business_scorecard)
      page = Page.create!(name: "Welcome")

      patch easy_flow.manage_flow_path(flow), params: { flow: { intro_page_id: page.id } }

      assert_equal page, Flow::Summaries.new(flow).intro_page
    end

    test "saving the details stores the page the flow finishes on" do
      flow = easy_flow_definitions(:business_scorecard)
      page = Page.create!(name: "Result")

      patch easy_flow.manage_flow_path(flow), params: { flow: { summary_page_id: page.id } }

      assert_equal page, Flow::Summaries.new(flow).summary_page
    end

    test "the flow builder runs the admin check the host gave alembic" do
      Alembic.admin_authentication_method = :require_an_admin

      get easy_flow.manage_flows_path

      assert_redirected_to "/host-login"
    ensure
      Alembic.admin_authentication_method = nil
    end

    test "the flow builder is drawn in the admin layout the host gave alembic" do
      Alembic.admin_layout = "mailer"

      get easy_flow.manage_flows_path

      assert_select "meta[http-equiv=Content-Type]"
    ensure
      Alembic.admin_layout = nil
    end

    private

    def branching_flow
      EasyFlow::Definition.create!(host: "alembic", slug: "branching").tap do |flow|
        flow.record_definition(flowing("slug" => "branching", "entry" => "a",
          "nodes" => [ { "id" => "a", "type" => "question", "text" => "A?", "options" => [ "y", "n" ] },
                       { "id" => "gate", "type" => "condition", "step" => "a", "output" => "answer", "comparison" => "is", "answer" => "y" },
                       { "id" => "b", "type" => "question", "text" => "B?", "options" => [ "y" ] } ],
          "edges" => [ { "from" => "a", "to" => "gate" }, { "from" => "gate", "to" => "b", "on" => true } ]))
        flow.publish
      end
    end

    def straight_flow
      EasyFlow::Definition.create!(host: "alembic", slug: "straight").tap do |flow|
        flow.record_definition(flowing("slug" => "straight", "entry" => "a",
          "nodes" => [ { "id" => "a", "type" => "question", "text" => "A?", "options" => [ { "value" => "y", "weight" => 1 } ] },
                       { "id" => "b", "type" => "question", "text" => "B?", "options" => [ { "value" => "y", "weight" => 1 } ] } ],
          "edges" => [ { "from" => "a", "to" => "b" } ]))
        flow.publish
      end
    end
  end
end
