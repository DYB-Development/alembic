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

    def alembic_default_result(output, outputs = [])
      case output.type
      when "percentage" then alembic_score_block(value: output.value, caption: output.label)
      when "band" then alembic_band_block(value: output.value, score: outputs.find { |other| other.type == "percentage" }&.value)
      when "grouped" then alembic_categories_block(value: output.value)
      when "lowest" then alembic_weakest_block(value: output.value)
      when "outcome" then alembic_outcome_block(value: output.value)
      else ui_stat_card(label: output.label, value: alembic_output_lines(output.value).join(" · "))
      end
    end

    def alembic_outcome_block(value: nil)
      chosen = value.to_h["chosen"]
      return "" if chosen.nil?

      render "alembic/blocks/outcome_entry", entry: chosen, open: true
    end

    def alembic_outcomes_block(value: nil, heading: nil)
      render "alembic/blocks/outcomes", entries: Array(value.to_h["entries"]), heading: heading
    end

    def alembic_tone(percentage)
      return "bg-red-500" if percentage.to_i < 40
      return "bg-amber-500" if percentage.to_i < 70

      "bg-emerald-500"
    end
  end
end
