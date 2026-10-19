require "test_helper"

module Alembic
  class OwnedCategoriesTest < ActionDispatch::IntegrationTest
    setup do
      Alembic.owner_method = :current_customer
      @ours = Customer.create!(name: "Ours")
      @theirs = Customer.create!(name: "Theirs")
    end

    teardown { Alembic.owner_method = nil }

    test "the category list shows only the owner's categories" do
      Category.create!(name: "Their rivers", owner: @theirs)

      get alembic.manage_categories_path, headers: as(@ours)

      assert_no_match "Their rivers", response.body
    end

    private

    def as(customer)
      { "X-Customer" => customer.id.to_s }
    end
  end
end
