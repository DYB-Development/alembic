module Alembic
  module ResultBlocksHelper
    def alembic_score_block(value: nil, caption: nil, kicker: "Your result")
      render "alembic/blocks/score", value: value, caption: caption, kicker: kicker
    end
  end
end
