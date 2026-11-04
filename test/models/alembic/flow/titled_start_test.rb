require "test_helper"

module Alembic
  module Flow
    class TitledStartTest < ActiveSupport::TestCase
      test "a flow takes a slug made from its title" do
        assert_equal "morning-routine", started("Morning Routine").slug
      end

      test "a second flow with the same title takes the next free number" do
        started("Morning Routine")

        assert_equal "morning-routine-2", started("Morning Routine").slug
      end

      private

      def started(title, host: "alembic", owner: nil)
        EasyFlow::Definition.new(host: host, owner: owner, title: title).tap { |flow| TitledStart.new(flow).save }
      end
    end
  end
end
