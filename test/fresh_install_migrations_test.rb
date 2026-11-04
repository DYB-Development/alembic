require "test_helper"
require "open3"

class FreshInstallMigrationsTest < ActiveSupport::TestCase
  MIGRATE_AN_EMPTY_DATABASE = <<~RUBY
    require "bundler/setup"
    require "tmpdir"
    ENV["RAILS_ENV"] = "test"
    require "./test/dummy/config/environment"

    Dir.mktmpdir do |dir|
      ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: File.join(dir, "fresh.sqlite3"))
      ActiveRecord::Migration.verbose = false
      ActiveRecord::MigrationContext.new([ EasyFlow::Engine.root.join("db/migrate").to_s, "db/migrate" ]).migrate
      puts ActiveRecord::Base.connection.tables.join(" ")
    end
  RUBY

  COLUMNS_OF_A_FLOW = MIGRATE_AN_EMPTY_DATABASE.sub(
    "ActiveRecord::Base.connection.tables.join", "ActiveRecord::Base.connection.columns(:easy_flow_definitions).map(&:name).join"
  ).freeze

  test "alembic's migrations run in order after easy_flow's from an empty database" do
    output, status = Open3.capture2e(RbConfig.ruby, "-e", MIGRATE_AN_EMPTY_DATABASE, chdir: Alembic::Engine.root.to_s)

    assert status.success?, output
  end

  test "a fresh install stores no kind on a flow" do
    output, _status = Open3.capture2e(RbConfig.ruby, "-e", COLUMNS_OF_A_FLOW, chdir: Alembic::Engine.root.to_s)

    assert_not_includes output.split, "kind", output
  end

  test "alembic's migrations create no category or question tables" do
    output, _status = Open3.capture2e(RbConfig.ruby, "-e", MIGRATE_AN_EMPTY_DATABASE, chdir: Alembic::Engine.root.to_s)

    assert_empty output.split & %w[alembic_categories alembic_questions], output
  end
end
