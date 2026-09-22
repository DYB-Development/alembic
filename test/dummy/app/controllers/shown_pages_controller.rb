require "ks_blocks/layout_helper"

class ShownPagesController < ApplicationController
  helper KeystoneUiHelper
  helper KsBlocks::LayoutHelper
  helper Alembic::PagesHelper

  def show
    @page = Alembic::Page.find(params[:id])
  end
end
