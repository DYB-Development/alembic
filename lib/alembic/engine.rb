require "alembic/leftover_stylesheet"
require "keystone_ui-blocks"
require "keystone_ui-react"
require "easy_flow"

module Alembic
  class Engine < ::Rails::Engine
    isolate_namespace Alembic

    initializer "alembic.remove_leftover_stylesheet" do |app|
      Alembic::LeftoverStylesheet.new(app.root).remove
    end

    initializer "alembic.tailwind" do
      next unless Gem.loaded_specs.key?("keystone_ui")

      require "keystone_ui"
      KeystoneUi.configuration.tailwind_sources << root.join("app/views/**/*.erb").to_s
      KeystoneUi.configuration.tailwind_sources << root.join("app/javascript/**/*.{js,jsx}").to_s
      KeystoneUi.configuration.tailwind_sources << root.join("app/assets/builds/alembic/*.js").to_s
    end

    initializer "alembic.output_types" do |app|
      app.config.to_prepare do
        Alembic::Outputs::WeightedSum.register
        Alembic::Outputs::Percentage.register
        Alembic::Outputs::Grouped.register
        Alembic::Outputs::Lowest.register
        Alembic::Outputs::Tally.register
        Alembic::Outputs::Band.register
      end
    end
  end
end
