# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Changed
- **Flows** — flows, their versions and their runs are easy_flow's, which Alembic now depends on at 0.3. Alembic's own copy of the flow layer, the canvas editor and their tables are gone, and a host that registered step types does so with `EasyFlow.step` in place of `Alembic::Flow.step`.
- **The flow builder** — the flow builder, the canvas and the version history are easy_flow's pages, served at the same `manage/flows` address under Alembic's mount. Links to them come from the `easy_flow` route helper in place of the `alembic` one.
- **A flow's summary text** — an author writes it on the flow's details page, since easy_flow's canvas panel does not offer it.
- **Settings** — each of Alembic's settings also sets easy_flow's setting of the same name, so a host keeps setting Alembic's.
- **Refusals** — `Alembic::NotPublished`, `Alembic::NotPermitted`, `Alembic::Withdrawn` and `Alembic::OutOfService` are easy_flow's classes of the same name, so a refusal's class is named `EasyFlow::` while matching on Alembic's names still works.
- **Arranging a page** — the page builder's grid shows the page and nothing else until a designer presses Edit. Adding a block, moving one, resizing one and removing one all wait behind that, and the block types are offered in a dialog rather than beside the grid.
- **Removing a block** — a block is removed by dragging it onto the target that appears while the page is being edited, where it carried a Remove control.
- **Moving a block** — a block being edited is moved from any point on it. Holding a block for half a second starts editing, so on a touchscreen a finger that is not held scrolls the page.
- **The builder's card** — Alembic draws the card around the page builder, which the block grid drew until it stopped drawing one of its own.
- **The block grid** — Alembic takes `keystone_ui-blocks` at 0.7.0, where it took 0.2.0.

### Added
- **What a visitor is shown** — a visitor opening a page is shown the blocks of the live version, and a page with no live version is refused the way a flow that has never been published is. A developer asking the helper for the blocks being edited gets those instead.
- **Publishing a page** — a designer publishes a page from the builder and the blocks as they stand are recorded as a numbered version, which becomes the live one. The version that was live is marked superseded, earlier versions keep the blocks they were recorded with, and a page that has never been published has no live version.
- **A page at its own address** — a page carries a slug no other page can hold, and a visitor opening that address is shown the finished page. An address no page holds is refused the way an unknown flow is, and a flow and a page may hold the same slug.
- **A component that does not exist** — registering a page block type that names a component nothing draws is refused when the type is registered, and the message names the type and the component. A developer finds the mistake at boot rather than when a designer adds the block.
- **A block's body** — a page block type names the content field that becomes its component's body, so a designer types a paragraph into the block and sees it inside the drawn component. A field left empty draws no body, and what a designer types is escaped rather than treated as markup.
- **A block that cannot be drawn** — a block whose component raises says so on the block, and the rest of the grid is drawn and stays editable. The finished page leaves that block out, and the reason goes to the application's log.
- **A component's options** — a page block type maps a content field onto a differently named option, gives an option a default for when the field is empty, and fixes an option's value for every block of that type. A block whose component needs a value can be dropped onto a page and drawn straight away.
- **A finished page** — a host app draws a page's blocks with one call, each block drawn with the keystone_ui component its type names and placed where the designer put it. A block whose type names no component is left out.

### Fixed
- **A block being filled in** — a block on the grid is drawn again as a designer types into its fields, where it kept the markup it was first given until the page was reloaded.

### Changed
- **Block grid** — the page builder's grid, the block types a host registers and the layout a host keeps come from `keystone_ui-blocks`, which Alembic now depends on, instead of Alembic's own copy of them. A host app installs nothing for this, and a host that registered block types or kept a layout carries on unchanged.
- **React controls** — the flow editor and the page builder draw with the controls from `keystone_ui-react`, which Alembic now depends on, instead of Alembic's own copies of them. A host app installs nothing for this.
- **One React per page** — Alembic's scripts carry no React of their own and read it from the page, which loads it once from `keystone_ui-react`. A page with another React engine on it downloads React once rather than once per engine.

### Fixed
- **Generated stylesheet** — hosts no longer get `app/assets/builds/tailwind/alembic.css`. With `stylesheet_link_tag :app`, that file made the browser request a path inside the installed gem and raise a routing error. When `keystone_ui` is installed, Alembic's views and React source now come in through `keystone_source.css`.

### Upgrading
- Run `bin/rails easy_flow:install:migrations` before `bin/rails alembic:install:migrations`, then migrate. Alembic's migration drops `alembic_flows`, `alembic_flow_versions` and `alembic_flow_runs`, clears the summary versions that belonged to them, and keeps summary data in `alembic_flow_definition_summaries` and `alembic_flow_run_summaries`, keyed to easy_flow's tables.
- Do not mount easy_flow in the host's routes, since Alembic mounts it.
- Remove `@import "../builds/tailwind/alembic";` from `app/assets/tailwind/application.css`.
- Alembic deletes the leftover `app/assets/builds/tailwind/alembic.css` when the host app boots, so there is nothing to delete by hand.
