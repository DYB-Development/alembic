require "application_system_test_case"

module Alembic
  class TurboVisitTest < ApplicationSystemTestCase
    test "the page builder still adds a block on a second visit to the page" do
      Page.create!(name: "Welcome")
      visit alembic.manage_pages_path
      click_on "Welcome"
      find("[data-block-grid]")

      click_on "All pages"
      click_on "Welcome"

      click_on "Edit"
      click_on "Add a block"
      assert_selector "[data-block-type='heading']"
      find("[data-block-type='heading'] button", text: "Add").click

      assert_selector "[data-block]", text: "Heading"
    end
  end
end
