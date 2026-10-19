require "test_helper"

module Alembic
  class CategoryTest < ActiveSupport::TestCase
    test "a category needs a name" do
      assert_not Category.new(name: "").valid?
    end
  end
end
