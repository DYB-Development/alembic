require "test_helper"

module Alembic
  class PreviewTest < ActionDispatch::IntegrationTest
    def unpublished
      @unpublished ||= EasyFlow::Definition.create!(host: "alembic", slug: "unpublished").tap do |flow|
        flow.edit_history.edit_document(flowing(
          "slug" => "unpublished", "entry" => "budget",
          "nodes" => [ { "id" => "budget", "type" => "question", "question" => "Budget?",
                         "answers" => [ { "value" => "high", "label" => "Generous", "weight" => 5 } ] },
                       { "id" => "end", "type" => "terminal" } ],
          "edges" => [ { "from" => "budget", "to" => "end" } ]
        ))
        flow.create_version
      end
    end

    test "finishing a flow being tried shows what its summary makes of it" do
      Flow::Summaries.new(unpublished).record("outputs" => [ { "id" => "score", "type" => "weighted_sum", "label" => "Your score" } ])

      get alembic.step_manage_flow_preview_path(unpublished), params: { answers: { budget: "high" } }

      assert_select "[data-output=?]", "score", text: /5/
    end

    test "trying a flow asks its first question at the preview's address" do
      get alembic.step_manage_flow_preview_path(unpublished)

      assert_select "form[action=?]", alembic.step_manage_flow_preview_path(unpublished), /Budget\?/
    end

    test "reaching the end of a flow being tried offers a way to start over" do
      get alembic.step_manage_flow_preview_path(unpublished), params: { answers: { budget: "high" } }

      assert_select "a[href=?]", alembic.manage_flow_preview_path(unpublished)
    end
  end
end
