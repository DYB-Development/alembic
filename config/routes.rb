Alembic::Engine.routes.draw do
  namespace :manage do
    resources :pages, only: [ :index, :create, :show ] do
      post "publish", on: :member
      get "layout", to: "page_blocks#layout", as: :layout
      post "blocks", to: "page_blocks#add_block", as: :blocks
      patch "blocks", to: "page_blocks#place_blocks"
      patch "blocks/:block_id", to: "page_blocks#fill_block"
      delete "blocks/:block_id", to: "page_blocks#remove_block", as: :block
    end

    resources :flows, only: [ :edit, :update ]
  end

  constraints(->(request) { request.path_info.match?(%r{\A/manage/flows(/|\z)}) }) do
    mount EasyFlow::Engine, at: "/"
  end

  post ":slug/runs", to: "flows#start", as: :flow_runs
  get "runs/:id", to: "flows#step", as: :run
  patch "runs/:id", to: "flows#update"

  get "pages/:slug", to: "pages#show", as: :page

  get ":slug", to: "flows#show", as: :flow
  get ":slug/step", to: "flows#step", as: :flow_step
end
