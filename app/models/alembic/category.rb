module Alembic
  class Category < ApplicationRecord
    belongs_to :owner, polymorphic: true, optional: true

    validates :name, presence: true
  end
end
