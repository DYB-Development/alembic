require "test_helper"

module Alembic
  module Flow
    class TitledStartTest < ActiveSupport::TestCase
      test "a flow takes a slug made from its title" do
        assert_equal "morning-routine", started("Morning Routine").slug
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
