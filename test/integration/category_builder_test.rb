require "test_helper"

module Alembic
  class CategoryBuilderTest < ActionDispatch::IntegrationTest
    test "creating a category saves it by name" do
      post alembic.manage_categories_path, params: { category: { name: "Rivers" } }

      assert Category.exists?(name: "Rivers")
    end
  end
end
