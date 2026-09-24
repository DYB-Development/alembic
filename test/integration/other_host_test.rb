require "test_helper"

module Alembic
  class OtherHostTest < ActionDispatch::IntegrationTest
    def console_flow
      @console_flow ||= EasyFlow::Definition.create!(host: "console", slug: "console-setup", title: "Console setup").tap do |flow|
        flow.record_definition(flowing("entry" => "ask",
          "nodes" => [ { "id" => "ask", "type" => "question", "text" => "Ready?", "options" => [ "yes" ] } ]))
        flow.publish
      end
    end

    test "alembic's visitor pages do not find a flow of another host" do
      get alembic.flow_path(console_flow.slug)

      assert_response :not_found
    end
  end
end
