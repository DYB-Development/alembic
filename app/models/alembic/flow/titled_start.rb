module Alembic
  module Flow
    class TitledStart
      FALLBACK_SLUG = "quiz"
      SLUGS_THE_ROUTES_USE = %w[manage pages runs].freeze

      def initialize(flow)
        @flow = flow
      end

      def save
        return refuse_blank_title if @flow.title.blank?

        begin
          @flow.slug = free_slug
          @flow.save
        rescue ActiveRecord::RecordNotUnique
          retry
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
