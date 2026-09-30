module Alembic
  module ResultBlocksHelper
    def alembic_score_block(value: nil, caption: nil, kicker: "Your result")
      render "alembic/blocks/score", value: value, caption: caption, kicker: kicker
    end

    def alembic_band_block(value: nil, score: nil)
      render "alembic/blocks/band", band: value.to_h, tone: alembic_tone(score)
    end

    def alembic_tone(percentage)
      return "bg-red-500" if percentage.to_i < 40

      "bg-amber-500"
    end
  end
end
