require "test_helper"

module Alembic
  class PageTest < ActiveSupport::TestCase
    test "is invalid without a name" do
      assert_not Page.new(name: "").valid?
    end
  end
end
