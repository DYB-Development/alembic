# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [ File.expand_path("../test/dummy/db/migrate", __dir__) ]
ActiveRecord::Migrator.migrations_paths << File.expand_path("../db/migrate", __dir__)
require "rails/test_help"

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.fixture_paths = [ File.expand_path("fixtures", __dir__) ]
  ActionDispatch::IntegrationTest.fixture_paths = ActiveSupport::TestCase.fixture_paths
  ActiveSupport::TestCase.file_fixture_path = File.expand_path("fixtures", __dir__) + "/files"
  ActiveSupport::TestCase.fixtures :all
end

# Builds a flow document from the shape a test cares about — the steps and the
# connections — supplying the beginning a flow needs so a change to that shape
# lands here rather than in every fixture.
module BuildsFlows
  def flowing(document)
    beginning = document["entry"]

    document.except("entry").merge(
      "nodes" => [ { "id" => "start", "type" => "start" } ] + Array(document["nodes"]),
      "edges" => (beginning ? [ { "from" => "start", "to" => beginning } ] : []) + Array(document["edges"])
    )
  end
end

ActiveSupport::TestCase.include BuildsFlows
ActionDispatch::IntegrationTest.include BuildsFlows

# Keeps the page block types a host registered at boot, so a test that registers
# its own gives them back rather than leaving later tests without them.
module KeepsPageBlocks
  def declarations
    {
      components: Alembic::Page::Drawing.components.dup,
      options: Alembic::Page::Options.declared.dup,
      bodies: Alembic::Page::Options.bodies.dup
    }
  end

  def restore(kept)
    Alembic::Page::Drawing.instance_variable_set(:@components, kept[:components])
    Alembic::Page::Options.instance_variable_set(:@declared, kept[:options])
    Alembic::Page::Options.instance_variable_set(:@bodies, kept[:bodies])
  end
end

ActiveSupport::TestCase.include KeepsPageBlocks
