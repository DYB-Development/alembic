require "application_system_test_case"

module Alembic
  class CategoryBuilderPhoneTest < ApplicationSystemTestCase
    setup do
      page.driver.browser.manage.window.resize_to(400, 900)
      @category = Category.create!(name: "Rivers")
    end

    teardown do
      page.driver.browser.manage.window.resize_to(1400, 1000)
    end

    test "a category's page fits a phone without scrolling sideways" do
      visit alembic.manage_category_path(@category)

      assert_fits_the_screen
    end

    test "a phone shows a category's name" do
      visit alembic.manage_category_path(@category)

      assert_selector "h1", text: "Rivers"
    end

    test "a phone offers a new category from the category list" do
      visit alembic.manage_categories_path

      assert_link "New category", href: alembic.new_manage_category_path
    end

    test "a phone shows which kind of question is being written" do
      visit alembic.new_manage_category_question_path(@category, kind: "multiple_choice")

      assert_selector "h1", text: "New multiple choice question"
    end

    private

    def assert_fits_the_screen
      assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth")
    end
  end
end
