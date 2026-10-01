require "test_helper"

module Alembic
  class Page
    class PreviewTest < ActiveSupport::TestCase
      teardown { Preview.provider = @kept_provider }
      setup { @kept_provider = Preview.provider }

      test "asks the provider the flow side set for a page's preview values" do
        page = Page.create!(name: "Result")
        Preview.provider = ->(asked, _choice) { { "page" => asked.name } }

        assert_equal({ "page" => "Result" }, Preview.values_for(page, nil))
      end
    end
  end
end
