require "test_helper"
Dir[Rails.root.join("db/migrate/*_add_public_code_to_easy_flow_{definitions,versions}.easy_flow.rb")].each { |migration| require migration }

module Alembic
  class FlowsWithoutCodesTest < ActionDispatch::IntegrationTest
    def migrate(direction)
      ActiveRecord::Migration.suppress_messages do
        AddPublicCodeToEasyFlowDefinitions.new.public_send(direction)
        AddPublicCodeToEasyFlowVersions.new.public_send(direction)
      end
      EasyFlow::Definition.reset_column_information
      EasyFlow::Version.reset_column_information
    end

    setup { migrate(:down) }
    teardown { migrate(:up) }

    test "alembic's flow details page opens by the flow's id in an app whose flows have no codes" do
      flow = EasyFlow::Definition.create!(host: Alembic::FLOW_HOST.to_s, slug: "old", title: "Old")

      get "/alembic/manage/flows/#{flow.id}/edit"

      assert_response :success
    end
  end
end
