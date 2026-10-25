require "test_helper"

module Alembic
  class ShuffledAnswersTest < ActionDispatch::IntegrationTest
    BUILT = %w[a b c d e f].freeze

    def quiz
      @quiz ||= EasyFlow::Definition.create!(host: "alembic", slug: "shuffled", persists: :each_step).tap do |flow|
        flow.record_definition(flowing("slug" => "shuffled", "entry" => "pick",
          "nodes" => [ { "id" => "pick", "type" => "question", "question" => "Pick one",
                         "answers" => BUILT.map { |value| { "value" => value } } } ]))
        flow.publish
      end
    end

    test "a player sees a question's answers in a shuffled order when the quiz shuffles answers" do
      Flow::Summaries.new(quiz).shuffle_answers(true)

      assert_not_equal BUILT, shown_order(run_coded("first-player"))
    end

    test "a player sees a question's answers in their built order when the quiz does not shuffle answers" do
      assert_equal BUILT, shown_order(run_coded("first-player"))
    end

    private

    def run_coded(code)
      EasyFlow::Run.start(quiz).tap { |run| run.update!(public_code: code) }
    end

    def shown_order(run)
      get alembic.run_path(run)
      css_select("input[name='answers[pick]']").map { |input| input["value"] }
    end
  end
end
