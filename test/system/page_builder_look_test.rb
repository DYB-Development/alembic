require "application_system_test_case"

module Alembic
  class PageBuilderLookTest < ApplicationSystemTestCase
    test "a palette's accent color reaches the page builder's primary button" do
      visit alembic.manage_page_path(Page.create!(name: "Welcome"))
      page.execute_script(%(document.documentElement.style.setProperty("--color-accent-600", "rgb(1, 2, 3)")))

      assert_equal "rgb(1, 2, 3)", background_of(find("[data-all-pages]"))
    end

    test "choosing dark mode sets the page builder's panel on keystone's dark panel color" do
      visit alembic.manage_page_path(Page.create!(name: "Welcome"))
      page.execute_script(%(document.documentElement.dataset.theme = "dark"))

      assert_equal color_of_variable("--color-zinc-900"), background_of(find("[data-block-grid-panel]"))
    end

    private

    def color_of_variable(name)
      page.evaluate_script(<<~JS)
        (() => {
          const probe = document.createElement("div")
          probe.style.backgroundColor = "var(#{name})"
          document.body.appendChild(probe)
          const color = getComputedStyle(probe).backgroundColor
          probe.remove()
          return color
        })()
      JS
    end

    def background_of(element)
      page.evaluate_script("getComputedStyle(arguments[0]).backgroundColor", element)
    end
  end
end
