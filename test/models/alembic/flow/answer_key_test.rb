require "test_helper"

module Alembic
  module Flow
    class AnswerKeyTest < ActiveSupport::TestCase
      test "the key to a single-choice question is the answer that carries points" do
        step = { "type" => "question", "answers" => [ { "value" => "a", "weight" => 0 }, { "value" => "b", "weight" => 1 } ] }

        assert_equal "b", AnswerKey.chosen(step)
      end

      test "the key to a multiple-select question is every answer that carries points" do
        step = { "type" => "multiple_select", "answers" => [ { "value" => "a", "weight" => 1 }, { "value" => "b", "weight" => 0 }, { "value" => "c", "weight" => 1 } ] }

        assert_equal %w[a c], AnswerKey.chosen(step)
      end

      test "the key to a fill-in-the-blank question is its first accepted answer" do
        step = { "type" => "fill_in_the_blank", "accepted_answers" => [ { "value" => "Paris" }, { "value" => "Paree" } ] }

        assert_equal "Paris", AnswerKey.chosen(step)
      end
    end
  end
end
