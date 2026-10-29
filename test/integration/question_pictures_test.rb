require "test_helper"

module Alembic
  class QuestionPicturesTest < ActionDispatch::IntegrationTest
    class Store
      def url_of(reference)
        "/pictures/#{reference}"
      end
    end

    setup do
      @stored_with, EasyFlow.picture_store = EasyFlow.picture_store, Store.new
    end

    teardown do
      EasyFlow.picture_store = @stored_with
    end

    def quiz
      { "slug" => "pictured", "entry" => "france",
        "nodes" => [ { "id" => "france", "type" => "question", "question" => "Which country is this?", "picture" => "picture-1",
                       "answers" => [ { "value" => "france", "weight" => 1 }, { "value" => "spain" } ] },
                     { "id" => "flags", "type" => "multiple_select", "question" => "Which colours are on this flag?", "picture" => "picture-2",
                       "answers" => [ { "value" => "blue", "weight" => 1 }, { "value" => "red" } ] } ],
        "edges" => [ { "from" => "france", "to" => "flags" } ] }
    end

    def pictured
      @pictured ||= EasyFlow::Definition.create!(host: "alembic", slug: "pictured", persists: :each_step).tap { |flow| flow.record_definition(flowing(quiz)); flow.publish }
    end

    test "a player taking a quiz at their own pace sees a single-choice question's picture above the question" do
      post alembic.flow_runs_path(pictured.slug)

      get alembic.run_path(EasyFlow::Run.last)

      assert_select "fieldset img[src='/pictures/picture-1'] + legend", text: "Which country is this?"
    end

    test "a player sees a multiple select question's picture above the question" do
      post alembic.flow_runs_path(pictured.slug)
      run = EasyFlow::Run.last
      patch alembic.run_path(run), params: { answers: { france: "france" } }

      get alembic.run_path(run)

      assert_select "fieldset img[src='/pictures/picture-2'] + legend", text: "Which colours are on this flag?"
    end

    test "a player taking a quiz shown on one page sees each question's picture above its text" do
      Flow::Summaries.new(pictured).ask_on_one_page(true)

      get alembic.flow_step_path(pictured.slug)

      assert_equal [ "/pictures/picture-1", "/pictures/picture-2" ], css_select("fieldset img").map { |picture| picture["src"] }
    end

    test "a question's picture has alternative text naming it as the question's picture" do
      post alembic.flow_runs_path(pictured.slug)

      get alembic.run_path(EasyFlow::Run.last)

      assert_select "img[alt=?]", "The question's picture"
    end

    test "a question with no picture is drawn with no picture" do
      plain = EasyFlow::Definition.create!(host: "alembic", slug: "plain", persists: :each_step).tap do |flow|
        flow.record_definition(flowing(quiz.merge("slug" => "plain", "nodes" => quiz["nodes"].map { |node| node.except("picture") })))
        flow.publish
      end
      post alembic.flow_runs_path(plain.slug)

      get alembic.run_path(EasyFlow::Run.last)

      assert_select "img", count: 0
    end
  end
end
