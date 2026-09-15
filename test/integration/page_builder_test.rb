require "test_helper"

module Alembic
  class PageBuilderTest < ActionDispatch::IntegrationTest
    test "the page list shows each page by name" do
      Page.create!(name: "Welcome")

      get alembic.manage_pages_path

      assert_includes response.body, "Welcome"
    end

    test "creating a page saves it by name" do
      post alembic.manage_pages_path, params: { page: { name: "Welcome" } }

      assert Page.exists?(name: "Welcome")
    end
  end
end
