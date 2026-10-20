require "test_helper"

module Alembic
  class ManageAddressesTest < ActionDispatch::IntegrationTest
    test "nothing answers under the categories path" do
      get "/alembic/manage/categories"

      assert_response :not_found
    end
  end
end
