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

    test "opening a page mounts the page builder" do
      page = Page.create!(name: "Welcome")

      get alembic.manage_page_path(page)

      assert_select "[data-react-ui=?]", "alembic/page-builder"
    end

    test "the page builder is given the page's name" do
      page = Page.create!(name: "Welcome")

      get alembic.manage_page_path(page)

      assert_equal "Welcome", page_builder_props["name"]
    end

    test "the page builder is given the address of its page's endpoints" do
      page = Page.create!(name: "Welcome")

      get alembic.manage_page_path(page)

      assert_equal alembic.manage_page_path(page), page_builder_props["base"]
    end

    test "the page builder screen loads the page builder script" do
      page = Page.create!(name: "Welcome")

      get alembic.manage_page_path(page)

      assert_select "script[src*=?]", "alembic/page_builder"
    end

    test "the page builder is given the page list's address" do
      page = Page.create!(name: "Welcome")

      get alembic.manage_page_path(page)

      assert_equal alembic.manage_pages_path, page_builder_props["pages"]
    end

    test "the page list links each page to its page builder" do
      page = Page.create!(name: "Welcome")

      get alembic.manage_pages_path

      assert_select "a[href=?]", alembic.manage_page_path(page)
    end

    test "creating a page opens it in the page builder" do
      post alembic.manage_pages_path, params: { page: { name: "Welcome" } }

      assert_redirected_to alembic.manage_page_path(Page.find_by!(name: "Welcome"))
    end

    private

    def page_builder_props
      JSON.parse(css_select("[data-react-ui='alembic/page-builder']").first["data-props"])
    end
  end
end
