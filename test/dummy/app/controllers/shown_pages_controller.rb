require "ks_blocks/layout_helper"

class ShownPagesController < ApplicationController
  helper KeystoneUiHelper
  helper KsBlocks::LayoutHelper

  def show
    @page = Alembic::Page.find(params[:id])
  end
end
