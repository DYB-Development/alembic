require "test_helper"

class TailwindEntryPointTest < ActiveSupport::TestCase
  test "the engine ships a Tailwind entry point where a host build looks for it" do
    assert_path_exists entry_point
  end

  test "the entry point points Tailwind at the engine's views" do
    assert_equal Alembic::Engine.root.join("app/views/**/*.erb").to_s, scanned_glob
  end

  test "the entry point points Tailwind at the engine's React source" do
    assert_includes scanned_globs, Alembic::Engine.root.join("app/javascript/**/*.{js,jsx}").to_s
  end

  private

  def scanned_globs
    entry_point.read.scan(/@source\s+"([^"]+)"/).flatten.map { |glob| File.expand_path(glob, entry_point.dirname) }
  end

  def scanned_glob
    File.expand_path(entry_point.read[/@source\s+"([^"]+)"/, 1], entry_point.dirname)
  end

  def entry_point
    Alembic::Engine.root.join("app/assets/tailwind/#{Alembic::Engine.engine_name}/engine.css")
  end
end
