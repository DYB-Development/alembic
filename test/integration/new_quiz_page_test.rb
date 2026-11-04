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

    test "a quiz created from the page belongs to the current owner" do
      Alembic.owner_method = :current_customer
      owner = Customer.create!(name: "Ours")

      post "/alembic/manage/quizzes", params: { quiz: { title: "Morning Routine" } }, headers: { "X-Customer" => owner.id.to_s }

      assert_equal owner, EasyFlow::Definition.find_by!(host: "alembic", title: "Morning Routine").owner
    ensure
      Alembic.owner_method = nil
    end

    test "a second quiz with the same title for one owner gets a different slug" do
      Alembic.owner_method = :current_customer
      owner = Customer.create!(name: "Ours")

      2.times { post "/alembic/manage/quizzes", params: { quiz: { title: "Morning Routine" } }, headers: { "X-Customer" => owner.id.to_s } }

      assert_equal %w[morning-routine morning-routine-2], EasyFlow::Definition.where(host: "alembic", owner: owner).order(:id).pluck(:slug)
    ensure
      Alembic.owner_method = nil
    end

    test "the new quiz page runs the admin check the host gave alembic" do
      Alembic.admin_authentication_method = :require_an_admin

      get "/alembic/manage/quizzes/new"

      assert_redirected_to "/host-login"
    ensure
      Alembic.admin_authentication_method = nil
    end

    test "creating a quiz runs the admin check the host gave alembic" do
      Alembic.admin_authentication_method = :require_an_admin

      post "/alembic/manage/quizzes", params: { quiz: { title: "Morning Routine" } }

      assert_redirected_to "/host-login"
    ensure
      Alembic.admin_authentication_method = nil
    end

    test "editing a quiz's title leaves its slug alone" do
      post "/alembic/manage/quizzes", params: { quiz: { title: "Morning Routine" } }
      flow = EasyFlow::Definition.find_by!(host: "alembic", title: "Morning Routine")

      patch easy_flow.manage_flow_path(flow), params: { flow: { title: "Evening Routine" } }

      assert_equal "morning-routine", flow.reload.slug
    end

    test "the easy_flow new flow page still asks for a slug" do
      get "/alembic/manage/flows/new"

      assert_select "input[name=?]", "flow[slug]"
    end

    test "the easy_flow new flow page still creates a flow under the slug chosen" do
      post "/alembic/manage/flows", params: { flow: { slug: "chosen-slug" } }

      assert EasyFlow::Definition.exists?(host: "alembic", slug: "chosen-slug")
    end
  end
end
