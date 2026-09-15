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

    test "the page list offers a form to create a page by name" do
      get alembic.manage_pages_path

      assert_select "form[action=?] input[name=?]", alembic.manage_pages_path, "page[name]"
    end
  end
end
