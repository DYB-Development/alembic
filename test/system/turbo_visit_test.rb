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

    test "the flow editor listens for a renamed flow once however often it is visited" do
      Flow::Definition.create!(slug: "intake", title: "Intake")
      visit alembic.manage_flows_path
      page.execute_script(<<~COUNTING)
        window.ksNamedListeners = 0
        const adding = document.addEventListener.bind(document)
        document.addEventListener = (name, listener, options) => {
          if (name === "alembic:flow-named") window.ksNamedListeners += 1
          adding(name, listener, options)
        }
      COUNTING

      click_on "Intake"
      find("[data-flow-heading]")
      click_on "All diagnostics"
      click_on "Intake"
      find("[data-flow-heading]")

      assert_equal 1, page.evaluate_script("window.ksNamedListeners")
    end
  end
end
