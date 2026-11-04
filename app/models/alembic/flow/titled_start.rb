module Alembic
  module Flow
    class TitledStart
      FALLBACK_SLUG = "quiz"
      TRIES_FOR_A_FREE_SLUG = 3
      SLUGS_THE_ROUTES_USE = %w[manage pages runs].freeze

      def initialize(flow)
        @flow = flow
      end

      def save
        return refuse_blank_title if @flow.title.blank?

        tries = 0
        begin
          @flow.slug = free_slug
          @flow.save
        rescue ActiveRecord::RecordNotUnique
          retry if (tries += 1) < TRIES_FOR_A_FREE_SLUG
          raise
        end
      end

      private

      def refuse_blank_title
        @flow.errors.add(:title, :blank)
        false
      end

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
