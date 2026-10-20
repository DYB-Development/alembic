require "test_helper"

module Alembic
  module Flow
    class UploadedQuestionTest < ActiveSupport::TestCase
      def quiz
        @quiz ||= EasyFlow::Definition.create!(host: "alembic", slug: "quiz").tap do |flow|
          flow.record_definition(flowing("slug" => "quiz", "entry" => "first",
            "nodes" => [ { "id" => "first", "type" => "question", "question" => "First?",
                           "answers" => [ { "value" => "Yes", "weight" => 1 }, { "value" => "No" } ] } ]))
          flow.publish
        end
      end

      def row(values = {})
        UploadedQuestion.new({ flow: quiz, type: "Multiple choice", question: "Which planet is largest?", category: "Space",
                               answer_1: "Mars", answer_2: "Jupiter", answer_3: "Venus", right_answer: "2" }.merge(values))
      end

      def added_step
        EasyFlow::Document.new(quiz.reload.document).nodes.last
      end

      test "a saved row adds a question step asking its question" do
        row.save!

        assert_equal "Which planet is largest?", added_step.config["question"]
      end

      test "a saved multiple choice row offers its filled answers and weights the right one" do
        row.save!

        assert_equal [ { "value" => "Mars", "weight" => 0 }, { "value" => "Jupiter", "weight" => 1 }, { "value" => "Venus", "weight" => 0 } ],
          added_step.config["answers"]
      end

      test "a saved row sets its question's category" do
        row.save!

        assert_equal "Space", EasyFlow::Steps::Question.category_of(added_step.config)
      end

      test "a saved row is asked after the quiz's last question" do
        row.save!

        assert_equal [ added_step.id ], EasyFlow::Document.new(quiz.document).edges_from("first").map(&:to)
      end

      test "a saved true/false row offers True and False and weights the right one" do
        row(type: "True/false", question: "The Sun is a star.", answer_1: nil, answer_2: nil, answer_3: nil, right_answer: "true").save!

        assert_equal [ { "value" => "True", "weight" => 1 }, { "value" => "False", "weight" => 0 } ], added_step.config["answers"]
      end
    end
  end
end
