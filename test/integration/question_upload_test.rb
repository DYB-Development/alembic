require "test_helper"

module Alembic
  class QuestionUploadTest < ActionDispatch::IntegrationTest
    setup do
      Alembic.owner_method = :current_customer
      @ours = Customer.create!(name: "Ours")
      @theirs = Customer.create!(name: "Theirs")
    end

    teardown { Alembic.owner_method = nil }

    def quiz(owner = @ours)
      EasyFlow::Definition.create!(host: "alembic", slug: "quiz-#{owner.id}", owner: owner).tap do |flow|
        flow.record_definition(flowing("slug" => flow.slug, "entry" => "first",
          "nodes" => [ { "id" => "first", "type" => "question", "question" => "First?",
                         "answers" => [ { "value" => "Yes", "weight" => 1 }, { "value" => "No" } ] } ]))
        flow.publish
      end
    end

    def as(customer)
      { "X-Customer" => customer.id.to_s }
    end

    test "the upload page for a quiz lists the fields a file's columns are matched to" do
      get ixport.new_import_path(key: :quiz_questions, target: quiz.to_global_id), headers: as(@ours)

      assert_select "[data-expected-field]", text: "Right answer"
    end

    test "a builder cannot open the upload page for another owner's quiz" do
      get ixport.new_import_path(key: :quiz_questions, target: quiz(@theirs).to_global_id), headers: as(@ours)

      assert_response :not_found
    end
  end
end
