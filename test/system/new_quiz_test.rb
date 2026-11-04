require "application_system_test_case"

module Alembic
  class NewQuizTest < ApplicationSystemTestCase
    setup do
      page.driver.browser.manage.window.resize_to(400, 900)
    end

    teardown do
      page.driver.browser.manage.window.resize_to(1400, 1000)
    end

    test "a phone starts a quiz by typing its title and reaches the builder" do
      visit alembic.new_manage_quiz_path
      fill_in "quiz[title]", with: "Morning Routine"
      click_button "Create"

      assert_selector "[data-flow-canvas]"
    end
  end
end
