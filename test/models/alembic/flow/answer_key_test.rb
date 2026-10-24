require "test_helper"

module Alembic
  module Flow
    class AnswerKeyTest < ActiveSupport::TestCase
      test "the key to a single-choice question is the answer that carries points" do
        step = { "type" => "question", "answers" => [ { "value" => "a", "weight" => 0 }, { "value" => "b", "weight" => 1 } ] }

        assert_equal "b", AnswerKey.chosen(step)
      end
    end
  end
end
