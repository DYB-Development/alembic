Ixport.configure do |config|
  config.authentication_method = :require_a_customer
  config.current_person_method = :current_customer
  config.current_account_method = :current_customer
end

Ixport.register_import :quiz_questions, title: "Quiz questions", importer: "Alembic::QuestionImporter", refuse_whole_file: true,
  allow: ->(_person, account, quiz) { Alembic::QuestionImporter.allows?(account, quiz) }
