require "application_system_test_case"

module Alembic
  class PageBuilderPhoneTest < ApplicationSystemTestCase
    setup do
      page.driver.browser.manage.window.resize_to(400, 900)
    end

    teardown do
      page.driver.browser.manage.window.resize_to(1400, 1000)
    end

    test "a phone shows the page's name" do
      visit alembic.manage_page_path(Page.create!(name: "Welcome"))

      assert_selector "h1", text: "Welcome"
    end
  end
end
