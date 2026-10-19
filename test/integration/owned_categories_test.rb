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

    test "a category created in the builder belongs to the owner" do
      post alembic.manage_categories_path, params: { category: { name: "Rivers" } }, headers: as(@ours)

      assert_equal @ours, Category.find_by!(name: "Rivers").owner
    end

    test "the builder cannot open another owner's category" do
      theirs = Category.create!(name: "Their rivers", owner: @theirs)

      get alembic.manage_category_path(theirs), headers: as(@ours)

      assert_response :not_found
    end

    private

    def as(customer)
      { "X-Customer" => customer.id.to_s }
    end
  end
end
