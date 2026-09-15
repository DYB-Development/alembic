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

    test "a host's place endpoint stores the positions and sizes it is sent" do
      record = Alembic::Page.create!(name: "Dashboard")
      record.add_block(BlockType.new(key: :text, name: "Text", width: 6, height: 2), x: 0, y: 0)

      with_routing do |routes|
        routes.draw { patch "/hosts/:id/blocks", to: "ks_blocks_host#place_blocks" }
        patch "/hosts/#{record.id}/blocks", params: { layout: [ { id: record.blocks.first["id"], x: 6, y: 1, w: 4, h: 3 } ] }, as: :json
      end

      assert_equal [ 6, 1, 4, 3 ], record.reload.blocks.first.values_at("x", "y", "w", "h")
    end

    test "a host's remove endpoint takes the block off its record" do
      record = Alembic::Page.create!(name: "Dashboard")
      record.add_block(BlockType.new(key: :text, name: "Text", width: 6, height: 2), x: 0, y: 0)

      with_routing do |routes|
        routes.draw { delete "/hosts/:id/blocks/:block_id", to: "ks_blocks_host#remove_block" }
        delete "/hosts/#{record.id}/blocks/#{record.blocks.first["id"]}", as: :json
      end

      assert_empty record.reload.blocks
    end

    test "a host's layout endpoint answers with its record's layout data" do
      record = Alembic::Page.create!(name: "Dashboard")
      record.add_block(BlockType.new(key: :text, name: "Text", width: 6, height: 2), x: 0, y: 0)

      with_routing do |routes|
        routes.draw { get "/hosts/:id/layout", to: "ks_blocks_host#layout" }
        get "/hosts/#{record.id}/layout", as: :json

        assert_equal record.reload.blocks, response.parsed_body["blocks"]
      end
    end
  end
end
