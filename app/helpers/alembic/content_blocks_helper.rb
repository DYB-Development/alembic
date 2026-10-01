module Alembic
  module ContentBlocksHelper
    def alembic_hero_block(headline: nil, kicker: nil, text: nil)
      render "alembic/blocks/hero", headline: headline, kicker: kicker, text: text
    end

    def alembic_facts_block(question_count: nil)
      facts = yield.to_s.lines.map(&:strip).compact_blank.map do |line|
        line.gsub("{question_count}", question_count.to_s).split("|", 2).map(&:strip)
      end
      render "alembic/blocks/facts", facts: facts
    end

    START_LOOK = "inline-flex items-center justify-center font-semibold rounded-lg bg-accent-600 text-white hover:bg-accent-500 px-6 py-3 cursor-pointer".freeze

    def alembic_start_block(start_path:, label: "Start →", starts_a_run: false)
      return button_to(label, start_path, method: :post, class: START_LOOK) if starts_a_run

      link_to label, start_path, class: START_LOOK
    end

    def alembic_code_block
      render "alembic/blocks/code", code: yield.to_s
    end

    def alembic_table_block
      heading, *rows = yield.to_s.lines.map(&:strip).compact_blank.map { |line| line.split("|").map(&:strip) }
      render "alembic/blocks/table", heading: heading.to_a, rows: rows
    end
  end
end
