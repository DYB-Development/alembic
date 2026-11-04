require "test_helper"

module Alembic
  class NewQuizPageTest < ActionDispatch::IntegrationTest
    test "the new quiz page asks for a title" do
      get "/alembic/manage/quizzes/new"

      assert_select "input[name=?]", "quiz[title]"
    end

    test "the new quiz page does not ask for a slug" do
      get "/alembic/manage/quizzes/new"

      assert_select "input[name*=?]", "slug", count: 0
    end

    test "a quiz created from the page has the title typed" do
      post "/alembic/manage/quizzes", params: { quiz: { title: "Morning Routine" } }

      assert EasyFlow::Definition.exists?(host: "alembic", title: "Morning Routine")
    end
  end
end
