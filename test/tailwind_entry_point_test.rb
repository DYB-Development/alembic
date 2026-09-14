require "test_helper"

class TailwindEntryPointTest < ActiveSupport::TestCase
  test "the engine has no Tailwind file for tailwindcss-rails to generate a host stylesheet from" do
    assert_not File.exist?(entry_point)
  end

  private

  def entry_point
    Alembic::Engine.root.join("app/assets/tailwind/#{Alembic::Engine.engine_name}/engine.css")
  end
end
