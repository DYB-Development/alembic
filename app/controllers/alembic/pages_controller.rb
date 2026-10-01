module Alembic
  class PagesController < ApplicationController
    include OwnedPages
    helper PagesHelper
    helper KsBlocks::LayoutHelper

    def show
      @page = shown_page
    end

    private

    def shown_page
      page = owned_pages.find_by(slug: params[:slug])
      raise NotPublished if page.nil? || page.live_version.nil?

      page
    end
  end
end
