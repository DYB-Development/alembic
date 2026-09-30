module Alembic
  module ResultBlocksHelper
    def alembic_score_block(value: nil, caption: nil, kicker: "Your result")
      render "alembic/blocks/score", value: value, caption: caption, kicker: kicker
    end

    def alembic_band_block(value: nil, score: nil)
      render "alembic/blocks/band", band: value.to_h, tone: alembic_tone(score)
    end

    def alembic_categories_block(value: nil, heading: "Where you stand, area by area")
      render "alembic/blocks/categories", shares: value.to_h, heading: heading
    end

    def alembic_weakest_block(value: nil, heading: "Your biggest blind spots", cost_label: "What it likely costs you:")
      render "alembic/blocks/weakest", categories: Array(value), heading: heading, cost_label: cost_label
    end

    def alembic_answers_block(value: nil, heading: "What you told us")
      render "alembic/blocks/answers", answers: Array(value), heading: heading
    end

    def alembic_lead_block(slug:, note: nil, heading: "The next step", blurb: nil, button: "Send", placeholder: "you@example.com")
      render "alembic/blocks/lead", address: Alembic.lead_address.call(slug), slug: slug, note: note,
        heading: heading, blurb: blurb, button: button, placeholder: placeholder
    end

    def alembic_default_result(output)
      case output.type
      when "percentage" then alembic_score_block(value: output.value, caption: output.label)
      else ui_stat_card(label: output.label, value: alembic_output_lines(output.value).join(" · "))
      end
    end

    def alembic_tone(percentage)
      return "bg-red-500" if percentage.to_i < 40
      return "bg-amber-500" if percentage.to_i < 70

      "bg-emerald-500"
    end
  end
end
