Alembic::Engine.routes.draw do
  namespace :manage do
    resources :pages, only: [ :index, :create, :show ] do
      get "layout", to: "page_blocks#layout", as: :layout
      post "blocks", to: "page_blocks#add_block", as: :blocks
      patch "blocks", to: "page_blocks#place_blocks"
      patch "blocks/:block_id", to: "page_blocks#fill_block"
      delete "blocks/:block_id", to: "page_blocks#remove_block", as: :block
    end

    resources :flows, only: [ :index, :create, :show, :edit, :update, :destroy ] do
      resource :definition, only: [ :edit, :update ]
      resource :preview, only: :show, controller: "previews" do
        get :step
      end
      resources :versions, only: :index do
        post :return, on: :member
      end

      resource :canvas, only: :show, controller: "canvas" do
        post   "steps",       action: :add_step
        patch  "steps/:step", action: :configure_step
        delete "steps/:step",      action: :remove_step
        patch  "steps/:step/move", action: :move_step
        post   "versions",    action: :create
        post   "publish",     action: :publish
        patch  "details",     action: :details
        post   "undo",        action: :undo
        post   "redo",        action: :redo
        post   "edges",       action: :connect
        delete "edges",       action: :disconnect
      end
    end
  end

  post ":slug/runs", to: "flows#start", as: :flow_runs
  get "runs/:id", to: "flows#step", as: :run
  patch "runs/:id", to: "flows#update"

  get "pages/:slug", to: "pages#show", as: :page

  get ":slug", to: "flows#show", as: :flow
  get ":slug/step", to: "flows#step", as: :flow_step
end
