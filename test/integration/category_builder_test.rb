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

    test "a category with no name is refused with the reason" do
      post alembic.manage_categories_path, params: { category: { name: "" } }

      assert_select "[role=alert]", text: "Name can't be blank"
    end

    test "the category list links to each category by name" do
      category = Category.create!(name: "Rivers")

      get alembic.manage_categories_path

      assert_select "a[href=?]", alembic.manage_category_path(category), text: "Rivers"
    end

    test "the category list links to the new category page" do
      get alembic.manage_categories_path

      assert_select "a[href=?]", alembic.new_manage_category_path
    end

    test "a category's page shows its name" do
      get alembic.manage_category_path(Category.create!(name: "Rivers"))

      assert_select "h1", text: "Rivers"
    end

    test "a category's page lists each question with its right answer" do
      category = Category.create!(name: "Rivers")
      category.questions.true_or_false(text: "The Nile flows north.", right: "True").save!

      get alembic.manage_category_path(category)

      assert_select "li", text: /The Nile flows north\.\s+Right answer: True/
    end

    test "a category's page links to adding a true/false question" do
      category = Category.create!(name: "Rivers")

      get alembic.manage_category_path(category)

      assert_select "a[href=?]", alembic.new_manage_category_question_path(category, kind: "true_false")
    end
  end
end
