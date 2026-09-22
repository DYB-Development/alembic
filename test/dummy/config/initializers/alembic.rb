Alembic.layout = "application"
Alembic.base_controller = "ApplicationController"
Alembic.visitor_authorization_method = :alembic_visitor_permitted?

Rails.application.config.to_prepare do
  Steps::Notify.register
  Steps::Deliver.register

  KsBlocks.block(:heading, name: "Heading", width: 12, height: 1, kind: :pages, fields: [ { key: :title, label: "Title" } ])
  KsBlocks.block(:text, name: "Text", width: 6, height: 2, kind: :pages)
  Alembic::Page.block(:section, name: "Section", width: 12, height: 2, drawn_by: :ui_section,
    fields: [ { key: :title, label: "Title" }, { key: :subtitle, label: "Subtitle" } ])
  Alembic::Page.block(:note, name: "Note", width: 6, height: 2, drawn_by: :ui_section,
    fields: [ { key: :title, label: "Title" } ])
end
