module Alembic
  class Page < ApplicationRecord
    module ContentBlocks
      def self.register
        Page.block(:alembic_hero, name: "Hero", width: 12, height: 3, drawn_by: :alembic_hero_block,
          fields: [ { key: :kicker, label: "Small label" }, { key: :headline, label: "Headline" }, { key: :text, label: "Text" } ])
        Page.block(:alembic_facts, name: "Facts", width: 12, height: 1, drawn_by: :alembic_facts_block,
          fields: [ { key: :facts, label: "Facts, one per line" } ], body: :facts,
          options: { question_count: { value: "question_count" } })
        Page.block(:alembic_table, name: "Table", width: 12, height: 4, drawn_by: :alembic_table_block,
          fields: [ { key: :rows, label: "Rows, one per line" } ], body: :rows)
        Page.block(:alembic_code, name: "Code", width: 12, height: 3, drawn_by: :alembic_code_block,
          fields: [ { key: :code, label: "Code" } ], body: :code)
        Page.block(:alembic_start, name: "Start button", width: 4, height: 1, drawn_by: :alembic_start_block,
          fields: [ { key: :label, label: "Label" } ],
          options: { start_path: { value: "start_path" }, starts_a_run: { value: "starts_a_run" } })
      end
    end
  end
end
