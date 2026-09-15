require "pathname"

module Alembic
  class LeftoverStylesheet
    def initialize(root)
      @root = Pathname.new(root)
    end

    def remove
      leftover = @root.join("app/assets/builds/tailwind/alembic.css")
      leftover.delete if leftover.exist?
    end
  end
end
