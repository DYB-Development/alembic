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
  end
end
