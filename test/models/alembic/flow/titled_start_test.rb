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

      test "a flow keeps the plain slug when only another host uses the title" do
        started("Morning Routine", host: "console")

        assert_equal "morning-routine", started("Morning Routine").slug
      end

      test "a flow keeps the plain slug when only another owner uses the title" do
        started("Morning Routine", owner: Customer.create!(name: "Theirs"))

        assert_equal "morning-routine", started("Morning Routine", owner: Customer.create!(name: "Ours")).slug
      end

      private

      def started(title, host: "alembic", owner: nil)
        EasyFlow::Definition.new(host: host, owner: owner, title: title).tap { |flow| TitledStart.new(flow).save }
      end
    end
  end
end
