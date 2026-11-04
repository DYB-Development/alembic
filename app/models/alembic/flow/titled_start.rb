module Alembic
  module Flow
    class TitledStart
      FALLBACK_SLUG = "quiz"
      SLUGS_THE_ROUTES_USE = %w[runs].freeze

      def initialize(flow)
        @flow = flow
      end

      def save
        @flow.slug = free_slug
        @flow.save
      end

      private

      def free_slug
        made = @flow.title.parameterize.presence || FALLBACK_SLUG
        numbered = (2..).lazy.map { |number| "#{made}-#{number}" }

        taken = unavailable

        [ made ].chain(numbered).find { |candidate| taken.exclude?(candidate) }
      end

      def unavailable
        EasyFlow::Definition.where(host: @flow.host, owner: @flow.owner).pluck(:slug) + SLUGS_THE_ROUTES_USE
      end
    end
  end
end
