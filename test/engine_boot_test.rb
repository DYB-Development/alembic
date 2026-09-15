require "test_helper"
require "tmpdir"

class EngineBootTest < ActiveSupport::TestCase
  test "removes the leftover stylesheet from the host when the host boots" do
    Dir.mktmpdir do |root|
      leftover = Pathname.new(root).join("app/assets/builds/tailwind/alembic.css")
      leftover.dirname.mkpath
      leftover.write(%(@import "/old/gem/engine.css";))

      boot_with_root(Pathname.new(root))

      assert_not leftover.exist?
    end
  end

  private

  def boot_with_root(root)
    host = Struct.new(:root).new(root)
    Alembic::Engine.initializers
      .find { |initializer| initializer.name == "alembic.remove_leftover_stylesheet" }
      .bind(Alembic::Engine.instance)
      .run(host)
  end
end
