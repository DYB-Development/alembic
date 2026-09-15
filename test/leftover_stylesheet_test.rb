require "test_helper"
require "tmpdir"
require "alembic/leftover_stylesheet"

class LeftoverStylesheetTest < ActiveSupport::TestCase
  test "removes the stylesheet tailwindcss-rails generated for older versions" do
    Dir.mktmpdir do |root|
      leftover = Pathname.new(root).join("app/assets/builds/tailwind/alembic.css")
      leftover.dirname.mkpath
      leftover.write(%(@import "/old/gem/engine.css";))

      Alembic::LeftoverStylesheet.new(root).remove

      assert_not leftover.exist?
    end
  end
end
