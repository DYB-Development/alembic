module Alembic
  class Category < ApplicationRecord
    belongs_to :owner, polymorphic: true, optional: true
    has_many :questions, dependent: :destroy

    validates :name, presence: true
  end
end
