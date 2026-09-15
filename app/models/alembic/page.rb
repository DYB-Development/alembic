module Alembic
  class Page < ApplicationRecord
    validates :name, presence: true
  end
end
