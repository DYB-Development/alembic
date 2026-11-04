module Alembic
  module Flow
    class TitledStart
      FALLBACK_SLUG = "quiz"

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

        [ made ].chain(numbered).find { |candidate| slugs_in_use.exclude?(candidate) }
      end

      def slugs_in_use
        @slugs_in_use ||= EasyFlow::Definition.where(host: @flow.host, owner: @flow.owner).pluck(:slug)
      end
    end
  end
end
