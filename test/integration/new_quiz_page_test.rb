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

    test "a quiz created from the page has a slug made from the title typed" do
      post "/alembic/manage/quizzes", params: { quiz: { title: "Morning Routine" } }

      assert_equal "morning-routine", EasyFlow::Definition.find_by!(host: "alembic", title: "Morning Routine").slug
    end

    test "creating a quiz goes to the flow's builder" do
      post "/alembic/manage/quizzes", params: { quiz: { title: "Morning Routine" } }

      assert_redirected_to "/alembic/manage/flows/#{EasyFlow::Definition.find_by!(host: "alembic", title: "Morning Routine").public_code}"
    end

    test "a second quiz with the same title gets a different slug" do
      2.times { post "/alembic/manage/quizzes", params: { quiz: { title: "Morning Routine" } } }

      assert_equal %w[morning-routine morning-routine-2], EasyFlow::Definition.where(host: "alembic", title: "Morning Routine").order(:id).pluck(:slug)
    end

    test "a blank title is sent back as unprocessable" do
      post "/alembic/manage/quizzes", params: { quiz: { title: "" } }

      assert_response :unprocessable_entity
    end

    test "a blank title on the page says the title cannot be blank" do
      post "/alembic/manage/quizzes", params: { quiz: { title: "" } }

      assert_select "*", text: /Title can.t be blank/
    end

    test "a slug posted to the page is ignored" do
      post "/alembic/manage/quizzes", params: { quiz: { title: "Morning Routine", slug: "typed-by-hand" } }

      assert_equal "morning-routine", EasyFlow::Definition.find_by!(host: "alembic", title: "Morning Routine").slug
    end
  end
end
