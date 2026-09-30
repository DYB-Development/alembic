require "test_helper"

module Alembic
  class FlowRunTest < ActionDispatch::IntegrationTest
    def flowed
      @flowed ||= EasyFlow::Definition.create!(host: "alembic", slug: "flowed").tap do |flow|
        flow.record_definition(flowing(
          "slug" => "flowed", "entry" => "budget",
          "nodes" => [ { "id" => "budget", "type" => "question", "text" => "What is your budget?", "tag" => "money",
                         "options" => [ { "value" => "low", "label" => "Modest", "weight" => 1 },
                                        { "value" => "high", "label" => "Generous", "weight" => 5 } ] },
                       { "id" => "gate", "type" => "condition", "step" => "budget", "output" => "answer", "comparison" => "is", "answer" => "high" },
                       { "id" => "posh", "type" => "question", "text" => "Which premium tier?",
                         "options" => [ { "value" => "a", "weight" => 3 } ] },
                       { "id" => "plain", "type" => "question", "text" => "Which basic tier?",
                         "options" => [ { "value" => "b", "weight" => 1 } ] } ],
          "edges" => [ { "from" => "budget", "to" => "gate" },
                       { "from" => "gate", "to" => "posh", "on" => true },
                       { "from" => "gate", "to" => "plain", "on" => false } ]
        ))
        flow.publish
      end
    end

    def page_titled(title)
      page_of(:section, "title" => title)
    end

    def page_of(block_type, content)
      Page.create!(name: "Result").tap do |page|
        page.add_block(KsBlocks.registry.block_types(kind: :pages).find { |type| type.key == block_type }, x: 0, y: 0)
        page.fill_block(page.blocks.first["id"], content)
        page.publish
      end
    end

    def with_figure_block
      registry, kept = KsBlocks.registry, declarations
      KsBlocks.instance_variable_set(:@registry, KsBlocks::Registry.new)
      Page.block(:figure, name: "Figure", width: 3, height: 1, drawn_by: :ui_badge,
        fields: [ { key: :output, label: "Output" } ], options: { label: { value_of: :output } })
      yield
    ensure
      KsBlocks.instance_variable_set(:@registry, registry)
      restore(kept)
    end

    def summarised
      flowed.tap do |flow|
        Flow::Summaries.new(flow).record(
          "outputs" => [
            { "id" => "score", "type" => "weighted_sum", "label" => "Your score" },
            { "id" => "share", "type" => "percentage", "label" => "of it answered well" },
            { "id" => "band", "type" => "band", "label" => "Where that puts you", "of" => "score",
              "bands" => [ { "ceiling" => 4, "name" => "Modest" }, { "name" => "Generous" } ] },
            { "id" => "areas", "type" => "grouped", "label" => "By area" },
            { "id" => "weakest", "type" => "lowest", "label" => "Weakest area", "of" => "areas" },
            { "id" => "answered", "type" => "tally", "label" => "Steps answered" }
          ]
        )
      end
    end

    test "a flow keeping a run at the end stores it once the flow finishes" do
      flowed.update!(persists: :on_finish)

      assert_difference -> { EasyFlow::Run.count }, 1 do
        get alembic.flow_step_path(flowed.slug), params: { answers: { budget: "high", posh: "a" } }
      end
    end

    test "a run kept at the end is pinned to the summary the flow is on" do
      summarised.update!(persists: :on_finish)

      get alembic.flow_step_path(flowed.slug), params: { answers: { budget: "high", posh: "a" } }

      assert_equal Flow::Summaries.new(flowed).current_version, Flow::Summaries.new(flowed).pinned_to(EasyFlow::Run.last)
    end

    test "a finished run shows what its summary makes of it" do
      get alembic.flow_step_path(summarised.slug), params: { answers: { budget: "high", posh: "a" } }

      assert_select "[data-output=?]", "score", text: /8/
    end

    test "a finished run names the band its score falls in" do
      get alembic.flow_step_path(summarised.slug), params: { answers: { budget: "high", posh: "a" } }

      assert_select "[data-output=?]", "band", text: /Generous/
    end

    test "the default summary page draws a percentage as a large score" do
      get alembic.flow_step_path(summarised.slug), params: { answers: { budget: "high", posh: "a" } }

      assert_select "[data-output=?] .text-7xl", "share"
    end

    test "the default summary page draws a band as a pill" do
      get alembic.flow_step_path(summarised.slug), params: { answers: { budget: "high", posh: "a" } }

      assert_select "[data-output=?] .rounded-full", "band", text: "Generous"
    end

    test "the default summary page draws a bar for each category" do
      get alembic.flow_step_path(summarised.slug), params: { answers: { budget: "high", posh: "a" } }

      assert_select "[data-output=?] span[style^=width]", "areas"
    end

    test "the default summary page draws a panel for each weakest category" do
      get alembic.flow_step_path(summarised.slug), params: { answers: { budget: "high", posh: "a" } }

      assert_select "[data-output=?] .ks-panel", "weakest"
    end

    test "the default summary page takes a lead when the host names a lead address" do
      Alembic.lead_address = ->(slug) { "/leads/#{slug}" }

      get alembic.flow_step_path(summarised.slug), params: { answers: { budget: "high", posh: "a" } }

      assert_select "form[action=?]", "/leads/flowed"
    ensure
      Alembic.lead_address = nil
    end

    test "a lead carries the note the host writes from the flow's results" do
      Alembic.lead_address = ->(slug) { "/leads/#{slug}" }
      Alembic.lead_note = ->(_title, results) { "Banded #{results['band']['name']}" }

      get alembic.flow_step_path(summarised.slug), params: { answers: { budget: "high", posh: "a" } }

      assert_select "input[name=note][value=?]", "Banded Generous"
    ensure
      Alembic.lead_address = nil
      Alembic.lead_note = nil
    end

    test "the default summary page takes no lead when the host names no lead address" do
      get alembic.flow_step_path(summarised.slug), params: { answers: { budget: "high", posh: "a" } }

      assert_select "input[name=email]", count: 0
    end

    test "the default summary page shows a band by its name alone" do
      get alembic.flow_step_path(summarised.slug), params: { answers: { budget: "high", posh: "a" } }

      assert_select "[data-output=?]", "band", text: /name/, count: 0
    end

    test "the default summary page shows each weakest area by its name alone" do
      get alembic.flow_step_path(summarised.slug), params: { answers: { budget: "high", posh: "a" } }

      assert_select "[data-output=?]", "weakest", text: /name/, count: 0
    end

    test "an answer stranded on an abandoned branch does not count toward the score" do
      get alembic.flow_step_path(summarised.slug), params: { answers: { budget: "low", posh: "a", plain: "b" } }

      assert_select "[data-output=?]", "score", text: /2/
    end

    test "a finished run reports a share for each area it touched" do
      get alembic.flow_step_path(summarised.slug), params: { answers: { budget: "high", posh: "a" } }

      assert_select "[data-output=?]", "areas", text: /money/
    end

    test "a finished run counts the steps it answered" do
      get alembic.flow_step_path(summarised.slug), params: { answers: { budget: "high", posh: "a" } }

      assert_select "[data-output=?]", "answered", text: /2/
    end

    test "a finished run shows the live blocks of the page its flow finishes on" do
      Flow::Summaries.new(summarised).finish_on(page_titled("Here is where you stand"))

      get alembic.flow_step_path(flowed.slug), params: { answers: { budget: "high", posh: "a" } }

      assert_select "[data-block]", text: /Here is where you stand/
    end

    test "a block naming an output is drawn with that output's value for the finished run" do
      with_figure_block do
        Flow::Summaries.new(summarised).finish_on(page_of(:figure, "output" => "score"))

        get alembic.flow_step_path(flowed.slug), params: { answers: { budget: "high", posh: "a" } }

        assert_select "[data-block]", text: "8"
      end
    end

    test "an answers block on a flow's own page lists each question answered" do
      Flow::Summaries.new(summarised).finish_on(page_of(:alembic_answers, {}))

      get alembic.flow_step_path(flowed.slug), params: { answers: { budget: "high", posh: "a" } }

      assert_select "[data-block] li", text: /What is your budget\?\s+Generous/
    end

    test "a flow whose own page was never published finishes on the default summary page" do
      Flow::Summaries.new(summarised).finish_on(Page.create!(name: "Draft"))

      get alembic.flow_step_path(flowed.slug), params: { answers: { budget: "high", posh: "a" } }

      assert_select "[data-output=?]", "score"
    end

    test "a question with a category shows the category above its text" do
      get alembic.flow_step_path(flowed.slug)

      assert_select "fieldset p", text: "money"
    end

    test "the step page counts the question being asked out of every question on its path" do
      get alembic.flow_step_path(flowed.slug), params: { answers: { budget: "high" } }

      assert_select "span", text: "Question 2 of 2"
    end

    test "a flow with no summary still shows what was said" do
      get alembic.flow_step_path(flowed.slug), params: { answers: { budget: "low", plain: "b" } }

      assert_select "[data-answer=?]", "budget"
    end

    test "the finished page shows each question in the look's muted text" do
      get alembic.flow_step_path(flowed.slug), params: { answers: { budget: "low", plain: "b" } }

      assert_select "[data-answer=budget] .ks-tone-muted", text: "What is your budget?"
    end

    test "the finished page shows each answer in the look's text colour" do
      get alembic.flow_step_path(flowed.slug), params: { answers: { budget: "low", plain: "b" } }

      assert_select "[data-answer=budget] .ks-tone-neutral", text: "Modest"
    end

    test "the finished page weighs each answer with the look's medium weight" do
      get alembic.flow_step_path(flowed.slug), params: { answers: { budget: "low", plain: "b" } }

      assert_select "[data-answer=budget] [class~=?]", "font-(weight:--ks-font-weight-medium)", text: "Modest"
    end

    test "the finished page divides its answers with the look's divider colour" do
      get alembic.flow_step_path(flowed.slug), params: { answers: { budget: "low", plain: "b" } }

      assert_select "ul[class~=?] [data-answer=budget]", "divide-(color:--ks-color-divider)"
    end

    test "the finished page offers to start over at alembic's address for the flow" do
      get alembic.flow_step_path(flowed.slug), params: { answers: { budget: "low", plain: "b" } }

      assert_select "a[href=?]", alembic.flow_path(flowed.slug)
    end

    test "the intro shows the flow's summary under its title" do
      Flow::Summaries.new(flowed).describe("What this asks about")

      get alembic.flow_path(flowed.slug)

      assert_includes response.body, "What this asks about"
    end

    test "the intro links into the flow" do
      get alembic.flow_path(flowed.slug)

      assert_select "a[href=?]", alembic.flow_step_path(flowed.slug)
    end

    test "a visitor is asked the step the flow begins at" do
      get alembic.flow_step_path(flowed.slug)

      assert_select "legend", text: /What is your budget\?/
    end

    test "answering sends the visitor down the branch their answer selects" do
      get alembic.flow_step_path(flowed.slug), params: { answers: { budget: "high" } }

      assert_select "legend", text: /Which premium tier\?/
    end
  end
end
