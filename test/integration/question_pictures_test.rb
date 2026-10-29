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
  end
end
