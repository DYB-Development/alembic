module Alembic
  class Page < ApplicationRecord
    class Version < ApplicationRecord
      self.table_name = "alembic_page_versions"

      enum :status, { draft: "draft", live: "live", superseded: "superseded" }

      belongs_to :page, class_name: "Alembic::Page"

      validates :number, uniqueness: { scope: :page_id }
    end
  end
end
