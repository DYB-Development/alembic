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

      test "a title with no usable letters or numbers gets the plain fallback slug" do
        assert_equal "quiz", started("?!").slug
      end

      test "a title that makes the slug of the runs address takes the next number" do
        assert_equal "runs-2", started("Runs").slug
      end

      test "no title takes a slug that is the first word of one of alembic's routes" do
        words = Alembic::Engine.routes.routes.filter_map { |route| route.path.spec.to_s[%r{\A/([a-z]+)}, 1] }.uniq

        assert_empty words.map { |word| started(word.capitalize).slug } & words
      end

      private

      def started(title, host: "alembic", owner: nil)
        EasyFlow::Definition.new(host: host, owner: owner, title: title).tap { |flow| TitledStart.new(flow).save }
      end
    end
  end
end
