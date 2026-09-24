require "test_helper"

module Alembic
  module Flow
    class SummaryVersionTest < ActiveSupport::TestCase
      def flow
        @flow ||= EasyFlow::Definition.create!(slug: "demo")
      end

      test "is invalid when the flow already has that version number" do
        SummaryVersion.create!(flow: flow, number: 1, summary: { "outputs" => [] })

        duplicate = SummaryVersion.new(flow: flow, number: 1, summary: { "outputs" => [] })

        assert_not duplicate.valid?
      end

      test "refuses to be updated once persisted" do
        version = SummaryVersion.create!(flow: flow, number: 1, summary: { "outputs" => [] })

        assert_raises(ActiveRecord::ReadOnlyRecord) { version.update!(summary: { "outputs" => [ { "id" => "x" } ] }) }
      end

      test "is destroyed along with its flow" do
        SummaryVersion.create!(flow: flow, number: 1, summary: { "outputs" => [] })

        assert_difference -> { SummaryVersion.count }, -1 do
          flow.destroy!
        end
      end
    end
  end
end
