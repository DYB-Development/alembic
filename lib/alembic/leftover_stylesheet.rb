require "pathname"

module Alembic
  class LeftoverStylesheet
    def initialize(root)
      @root = Pathname.new(root)
    end

    def remove
      @root.join("app/assets/builds/tailwind/alembic.css").delete
    end
  end
end
