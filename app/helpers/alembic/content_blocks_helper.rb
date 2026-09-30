module Alembic
  module ContentBlocksHelper
    def alembic_hero_block(headline: nil, kicker: nil, text: nil)
      render "alembic/blocks/hero", headline: headline, kicker: kicker, text: text
    end
  end
end
