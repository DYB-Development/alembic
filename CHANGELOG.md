# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Changed
- **Moving a block** — a block on the page builder's grid is moved by the handle it now carries, so on a touchscreen a finger anywhere else on a block scrolls the page instead of moving the block.

### Changed
- **Block grid** — the page builder's grid, the block types a host registers and the layout a host keeps come from `keystone_ui-blocks`, which Alembic now depends on, instead of Alembic's own copy of them. A host app installs nothing for this, and a host that registered block types or kept a layout carries on unchanged.
- **React controls** — the flow editor and the page builder draw with the controls from `keystone_ui-react`, which Alembic now depends on, instead of Alembic's own copies of them. A host app installs nothing for this.
- **One React per page** — Alembic's scripts carry no React of their own and read it from the page, which loads it once from `keystone_ui-react`. A page with another React engine on it downloads React once rather than once per engine.

### Fixed
- **Generated stylesheet** — hosts no longer get `app/assets/builds/tailwind/alembic.css`. With `stylesheet_link_tag :app`, that file made the browser request a path inside the installed gem and raise a routing error. When `keystone_ui` is installed, Alembic's views and React source now come in through `keystone_source.css`.

### Upgrading
- Remove `@import "../builds/tailwind/alembic";` from `app/assets/tailwind/application.css`.
- Alembic deletes the leftover `app/assets/builds/tailwind/alembic.css` when the host app boots, so there is nothing to delete by hand.
