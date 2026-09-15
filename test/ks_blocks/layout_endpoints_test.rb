require "test_helper"
require "ks_blocks/layout_endpoints"

class KsBlocksHostController < ActionController::Base
  include KsBlocks::LayoutEndpoints

  private

  def block_layout_record
    Alembic::Page.find(params[:id])
  end
end

module KsBlocks
  class LayoutEndpointsTest < ActionDispatch::IntegrationTest
    test "a host's add endpoint puts a block of a registered type at the given place" do
      record = Alembic::Page.create!(name: "Dashboard")

      with_routing do |routes|
        routes.draw { post "/hosts/:id/blocks", to: "ks_blocks_host#add_block" }
        post "/hosts/#{record.id}/blocks", params: { type: "heading", x: 0, y: 2 }, as: :json
      end

      assert_equal [ [ "heading", 0, 2 ] ], record.reload.blocks.map { |block| block.values_at("type", "x", "y") }
    end
  end
end
