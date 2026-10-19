module Alembic
  class Question < ApplicationRecord
    enum :kind, { true_false: "true_false", multiple_choice: "multiple_choice" }

    belongs_to :category

    validate :two_options_or_more, if: :multiple_choice?

    def self.choice_of(text:, labels:, right:)
      options = labels.each_with_index.map { |label, index| { "label" => label, "right" => index.to_s == right.to_s } }
      new(kind: :multiple_choice, text: text, options: options)
    end

    private

    def two_options_or_more
      errors.add(:base, "A multiple choice question needs at least two options") if options.size < 2
    end
  end
end
