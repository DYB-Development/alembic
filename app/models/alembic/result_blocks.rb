module Alembic
  module ResultBlocks
    OUTPUT = { key: :output, label: "Output" }.freeze
    HEADING = { key: :heading, label: "Heading" }.freeze

    def self.register
      Page.block(:alembic_score, name: "Score", width: 12, height: 3, drawn_by: :alembic_score_block,
        fields: [ OUTPUT, { key: :kicker, label: "Label above" }, { key: :caption, label: "Caption" } ],
        options: { value: { value_of: :output } })
      Page.block(:alembic_band, name: "Band", width: 12, height: 2, drawn_by: :alembic_band_block,
        fields: [ OUTPUT, { key: :score, label: "Score output" } ],
        options: { value: { value_of: :output }, score: { value_of: :score } })
      Page.block(:alembic_categories, name: "Score per category", width: 12, height: 4, drawn_by: :alembic_categories_block,
        fields: [ OUTPUT, HEADING ], options: { value: { value_of: :output } })
      Page.block(:alembic_weakest, name: "Weakest categories", width: 12, height: 4, drawn_by: :alembic_weakest_block,
        fields: [ OUTPUT, HEADING, { key: :cost_label, label: "Cost label" } ], options: { value: { value_of: :output } })
      Page.block(:alembic_answers, name: "Answers given", width: 12, height: 4, drawn_by: :alembic_answers_block,
        fields: [ HEADING ], options: { value: { value: "answers" } })
    end
  end
end
