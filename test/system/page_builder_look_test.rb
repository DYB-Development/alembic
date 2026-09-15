require "application_system_test_case"

module Alembic
  class PageBuilderLookTest < ApplicationSystemTestCase
    test "a palette's accent color reaches the page builder's primary button" do
      visit alembic.manage_page_path(Page.create!(name: "Welcome"))
      page.execute_script(%(document.documentElement.style.setProperty("--color-accent-600", "rgb(1, 2, 3)")))

      assert_equal "rgb(1, 2, 3)", background_of(find("[data-all-pages]"))
    end

    private

    def background_of(element)
      page.evaluate_script("getComputedStyle(arguments[0]).backgroundColor", element)
    end
  end
end
