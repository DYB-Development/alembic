require "ks_blocks/layout"

module Alembic
  class Page < ApplicationRecord
    include KsBlocks::Layout

    block_layout :blocks, kind: :pages

    has_many :versions, class_name: "Alembic::Page::Version", dependent: :destroy, inverse_of: :page

    validates :name, presence: true
    validates :slug, uniqueness: true, allow_nil: true

    def publish
      versions.create!(number: next_number, blocks: blocks, status: :live)
    end

    def live_version
      versions.find_by(status: :live)
    end

    def next_number
      (versions.maximum(:number) || 0) + 1
    end

    def self.block(key, drawn_by: nil, options: {}, body: nil, **block_type)
      refuse_unknown(key, drawn_by)
      Drawing.record(key, drawn_by)
      Options.declare(key, options, body: body)
      KsBlocks.block(key, kind: :pages, **block_type)
    end

    def self.refuse_unknown(key, component)
      return if component.nil? || ApplicationController.helpers.respond_to?(component)

      raise ArgumentError, "The #{key} page block names #{component}, which nothing draws"
    end
    private_class_method :refuse_unknown
  end
end
