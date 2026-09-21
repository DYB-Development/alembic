# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Changed
- **Arranging a page** — the page builder's grid shows the page and nothing else until a designer presses Edit. Adding a block, moving one, resizing one and removing one all wait behind that, and the block types are offered in a dialog rather than beside the grid.
- **Removing a block** — a block is removed by dragging it onto the target that appears while the page is being edited, where it carried a Remove control.
- **Moving a block** — a block being edited is moved from any point on it. Holding a block for half a second starts editing, so on a touchscreen a finger that is not held scrolls the page.
- **The builder's card** — Alembic draws the card around the page builder, which the block grid drew until it stopped drawing one of its own.
- **The block grid** — Alembic takes `keystone_ui-blocks` at 0.7.0, where it took 0.2.0.

### Fixed
- **A block being filled in** — a block on the grid is drawn again as a designer types into its fields, where it kept the markup it was first given until the page was reloaded.

### Changed
- **Block grid** — the page builder's grid, the block types a host registers and the layout a host keeps come from `keystone_ui-blocks`, which Alembic now depends on, instead of Alembic's own copy of them. A host app installs nothing for this, and a host that registered block types or kept a layout carries on unchanged.
- **React controls** — the flow editor and the page builder draw with the controls from `keystone_ui-react`, which Alembic now depends on, instead of Alembic's own copies of them. A host app installs nothing for this.
- **One React per page** — Alembic's scripts carry no React of their own and read it from the page, which loads it once from `keystone_ui-react`. A page with another React engine on it downloads React once rather than once per engine.

### Fixed
- **Generated stylesheet** — hosts no longer get `app/assets/builds/tailwind/alembic.css`. With `stylesheet_link_tag :app`, that file made the browser request a path inside the installed gem and raise a routing error. When `keystone_ui` is installed, Alembic's views and React source now come in through `keystone_source.css`.

### Upgrading
- Remove `@import "../builds/tailwind/alembic";` from `app/assets/tailwind/application.css`.
- Alembic deletes the leftover `app/assets/builds/tailwind/alembic.css` when the host app boots, so there is nothing to delete by hand.
