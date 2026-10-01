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

  test "offers the page builder alembic's result blocks once the app boots" do
    assert_includes KsBlocks.registry.block_types(kind: :pages).map(&:key), :alembic_score
  end

  test "offers the page builder alembic's content blocks once the app boots" do
    assert_includes KsBlocks.registry.block_types(kind: :pages).map(&:key), :alembic_hero
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
