module Alembic
  class PagesController < ApplicationController
    helper PagesHelper
    helper KsBlocks::LayoutHelper

    def show
      @page = shown_page
    end

    private

    def shown_page
      Page.find_by(slug: params[:slug]) || raise(NotPublished)
    end
  end
end
