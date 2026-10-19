require "test_helper"

module Alembic
  class CategoryBuilderTest < ActionDispatch::IntegrationTest
    test "creating a category saves it by name" do
      post alembic.manage_categories_path, params: { category: { name: "Rivers" } }

      assert Category.exists?(name: "Rivers")
    end

    test "the new category page offers a form to name the category" do
      get alembic.new_manage_category_path

      assert_select "form[action=?] input[name=?]", alembic.manage_categories_path, "category[name]"
    end
  end
end
