require "test_helper"

module Alembic
  class HostLayoutTest < ActionDispatch::IntegrationTest
    test "the visitor guide renders inside the host application layout" do
      get alembic.flow_path(easy_flow_definitions(:db_guide).slug)

      assert_select "meta[name=application-name][content=Dummy]"
    end

    test "the host layout takes keystone's light theme when nothing else is chosen" do
      get alembic.manage_pages_path

      assert_select "html[data-theme=light]"
    end
  end
end
