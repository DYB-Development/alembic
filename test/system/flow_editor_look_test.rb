require "application_system_test_case"

module Alembic
  class FlowEditorLookTest < ApplicationSystemTestCase
    def flow
      @flow ||= Flow::Definition.create!(slug: "editor-look").tap do |diagnostic|
        diagnostic.record_definition(flowing(
          "slug" => "editor-look", "entry" => "first",
          "nodes" => [ { "id" => "first", "type" => "question", "question" => "First",
                         "answers" => [ { "value" => "yes" } ] } ],
          "edges" => []
        ))
      end
    end

    test "a palette's accent color reaches the flow panel's publish button" do
      canvas_for(flow)
      page.execute_script(%(document.documentElement.style.setProperty("--color-accent-600", "rgb(1, 2, 3)")))
      find("[data-open-panel]").click

      assert_equal "rgb(1, 2, 3)", background_of(find("[data-publish]"))
    end

    private

    def background_of(element)
      page.evaluate_script("getComputedStyle(arguments[0]).backgroundColor", element)
    end
  end
end
