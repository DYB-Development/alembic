Rails.application.routes.draw do
  get "/pages/:id/shown", to: "shown_pages#show"
  mount Alembic::Engine => "/alembic"
end
