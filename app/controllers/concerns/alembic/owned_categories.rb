module Alembic
  module OwnedCategories
    private

    def owned_categories
      return Category.all unless Alembic.owner_method

      Category.where(owner: send(Alembic.owner_method))
    end
  end
end
