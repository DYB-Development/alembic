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

    private

    def as(customer)
      { "X-Customer" => customer.id.to_s }
    end
  end
end
