require "test_helper"

module Alembic
  class OwnedPagesTest < ActionDispatch::IntegrationTest
    setup do
      Alembic.owner_method = :current_customer
      @ours = Customer.create!(name: "Ours")
      @theirs = Customer.create!(name: "Theirs")
    end

    teardown { Alembic.owner_method = nil }

    test "the page builder lists only the owner's pages" do
      Page.create!(name: "Our welcome", owner: @ours)
      Page.create!(name: "Their welcome", owner: @theirs)

      get alembic.manage_pages_path, headers: as(@ours)

      assert_no_match "Their welcome", response.body
    end

    test "a page created in the page builder belongs to the owner" do
      post alembic.manage_pages_path, params: { page: { name: "Fresh" } }, headers: as(@ours)

      assert_equal @ours, Page.find_by!(name: "Fresh").owner
    end

    test "the page builder cannot open another owner's page" do
      theirs = Page.create!(name: "Their welcome", owner: @theirs)

      get alembic.manage_page_path(theirs), headers: as(@ours)

      assert_response :not_found
    end

    test "a visitor opens a page's address only for the owner's pages" do
      Page.create!(name: "Their welcome", slug: "welcome", owner: @theirs).publish

      get alembic.page_path("welcome"), headers: as(@ours)

      assert_response :not_found
    end

    test "the details page offers a flow only the owner's published pages" do
      Page.create!(name: "Their result", owner: @theirs).publish

      get easy_flow.edit_manage_flow_path(owned_flow), headers: as(@ours)

      assert_select "option", text: "Their result", count: 0
    end

    test "a flow cannot finish on another owner's page" do
      theirs = Page.create!(name: "Their result", owner: @theirs).tap(&:publish)

      patch easy_flow.manage_flow_path(owned_flow), params: { flow: { summary_page_id: theirs.id } }, headers: as(@ours)

      assert_nil Flow::Summaries.new(owned_flow).summary_page
    end

    private

    def owned_flow
      @owned_flow ||= EasyFlow::Definition.create!(host: "alembic", slug: "ours", title: "Ours", owner: @ours)
    end

    def as(customer)
      { "X-Customer" => customer.id.to_s }
    end
  end
end
