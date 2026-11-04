require "test_helper"

module Alembic
  class NewQuizPageTest < ActionDispatch::IntegrationTest
    test "the new quiz page asks for a title" do
      get "/alembic/manage/quizzes/new"

      assert_select "input[name=?]", "quiz[title]"
    end
  end
end
