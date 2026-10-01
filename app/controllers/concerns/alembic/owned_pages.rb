module Alembic
  module OwnedPages
    private

    def owned_pages
      return Page.all unless Alembic.owner_method

      Page.where(owner: send(Alembic.owner_method))
    end
  end
end
