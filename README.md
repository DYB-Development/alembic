# Alembic

A diagnostics engine built on [easy_flow](https://github.com/DYB-Development/easy_flow):
easy_flow stores and runs the flows, and Alembic works out a summary of each
finished run and builds pages.

## Usage

easy_flow owns the flow layer: the flow document, step types, runs, versions,
the canvas editor, and the visitor and admin pages. Its README documents that
interface, including registering your own step types.

**[docs/consuming.md](docs/consuming.md)** documents what Alembic adds:
installing it, the settings a host gives it, the addresses it serves, the
summary layer and its output types, and deciding who may see a flow.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "alembic"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install alembic
```

Alembic's tables refer to easy_flow's, so install easy_flow's migrations first:
```bash
$ bin/rails easy_flow:install:migrations
$ bin/rails alembic:install:migrations
$ bin/rails db:migrate
```

Mount Alembic only. It mounts easy_flow's admin pages under its own
`manage/flows` address:
```ruby
mount Alembic::Engine => "/alembic"
```

## Styling

Alembic's views are written in Tailwind utility classes, and they render through
the [`keystone_ui`](https://github.com/tylercschneider/keystone_ui) component
gem. The gem ships no compiled stylesheet — your application's Tailwind build
produces the CSS, so it must scan the engine's views and React source and the
`keystone_ui` components, all inside installed gems.

Those paths resolve to machine-specific gem directories, so none of them can be
written as a literal in a committed stylesheet. When `keystone_ui` is installed,
Alembic registers its paths with `keystone_ui` at boot, and `keystone_ui` writes
every registered path into one file for you to import.

With [`tailwindcss-rails`](https://github.com/rails/tailwindcss-rails) v4,
install `keystone_ui`'s entry point:

```bash
$ bin/rails generate keystone:install
```

then import it in `app/assets/tailwind/application.css`:

```css
@import "tailwindcss";
@import "./keystone_source.css";
```

`keystone_source.css` is written at boot. It carries the `keystone_ui` component
path, its `accent` and `surface` color scales, and Alembic's view and React
source paths. It is a build artifact — gitignore it.

### Upgrading from an earlier Alembic

Remove `@import "../builds/tailwind/alembic";` from
`app/assets/tailwind/application.css`. Alembic deletes the leftover
`app/assets/builds/tailwind/alembic.css` when your app boots.

Finally, the engine has to render inside a layout that links your compiled CSS.
Point `Alembic.layout` (visitor pages) and `Alembic.admin_layout` (the builder)
at your own layouts:

```ruby
Alembic.layout = "application"
Alembic.admin_layout = "admin"
```

## The page builder bundle

The page builder is a React application built here and shipped as a committed
bundle, since a gem cannot run a JavaScript build on the host's machine. Host
applications need no Node toolchain; the bundle is served by the asset pipeline
like any other engine asset. The flow canvas comes from easy_flow.

Working on the page builder source in `app/javascript/alembic` means rebuilding
it:

```bash
$ npm install
$ npm run build
```

That writes `app/assets/builds/alembic/page_builder.js` and its stylesheet, both
of which are committed. CI rebuilds the bundle and fails if it differs from what
is committed.

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
