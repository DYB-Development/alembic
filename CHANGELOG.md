# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [0.4.2] - 2026-10-01

### Changed
- **Intro page values** — a flow's own intro page is drawn with each output's result for no answers yet and the flow's slug, so an outcome block on an intro page lists every entry.

## [0.4.1] - 2026-10-01

### Changed
- **Built intro and summary pages** — a flow's own intro or summary page is drawn in the same centred column, with the same padding, as the default pages and the step page.

## [0.4.0] - 2026-10-01

### Upgrading
- Run `bin/rails alembic:install:migrations` and then `bin/rails db:migrate`. Since 0.2.0 alembic has added columns for a flow's intro page, its summary page, showing answer values and asking on one page.
- Replace `Alembic.lead_partial` with `Alembic.lead_address`, and optionally `Alembic.lead_fields_partial` and `Alembic.lead_note`.
- Take easy_flow 0.6 or later, which alembic now requires.

### Added
- **Outcomes** — an outcome output holds a list of entries and an ordered list of rules on a visitor's answers, and chooses the entry named by the first rule whose conditions all hold. A condition can say an answer is a value or is not one, and a flow can hold several outcome outputs.
- **Outcome entries** — each entry carries a label, a name, a tagline, facts, sections with an optional result note drawn as a warning, and titled steps with code.
- **Outcome blocks** — the page builder offers a block that draws the chosen entry and a block that draws every entry with a link target for each, drawn the way the stats ladder's tier explorer is. The default summary page shows each outcome's chosen entry.
- **Editing outcomes** — an owner adds an outcome on a flow's details page and edits its rules, one per line, and its entries' facts, sections and steps in text boxes.
- **Editing results** — a flow's details page edits each output's label, a band output's bands with their names, ceilings and descriptions, and a weakest-categories output's count and each category's miss and cost copy. Saving records a new summary version, and a run pinned to an earlier version keeps its earlier results.
- **Questions with no category** — the details page of a flow scored by category lists each question with no category as a problem.
- **Previewing a page with results** — while laying out a page a flow starts or finishes on, an owner sees each block drawn with that flow's values. The values come from sample results worked out from the flow's own outputs, or from a finished run the owner picks.
- **Previewing the default pages** — a flow's details page links to a preview of its intro page and of its summary page with sample results.
- **A preview hook** — the page builder asks `Alembic::Page::Preview` for the values and choices to preview a page with, and the flow side answers. The page builder itself never names a flow or a run.
- **A flow's own intro page** — an owner chooses, on a flow's details page, a published page for the flow to start on, and a visitor opening the flow sees that page's live blocks.
- **The default intro page** — a flow with no intro page of its own opens on a page with its title, summary, question count and start button, drawn the way dyb_web's scorecard intro is.
- **Content blocks** — the page builder offers a hero with a small label, headline and text, a row of facts, a table, code and a start button. A fact written as `{question_count}` shows the flow's question count, and the start button starts the flow the page belongs to.
- **One-page flows** — an owner can set a flow with no branching, on its details page, to ask every question on one page. A visitor sees one question at a time with its category, count and progress bar, moves on by choosing an answer, goes back with Previous, and sends every answer in one request from a ready state at the end. A visitor whose browser runs no script sees every question at once.
- **Alembic's own step page** — a question is asked on a page drawn the way dyb_web's labs draw one, with the question's category above its text, "Question N of M" and a progress bar worked out from the questions answered and the questions left.
- **Moving on when an answer is chosen** — choosing an answer sends it on without pressing Next.
- **Answer values beside their labels** — an owner can set a flow, on its details page, to show each answer's value beside its label.

### Changed
- **Unregistered output types** — recording a summary version refuses an output that names a type nobody registered, and the refusal names the type.
- **easy_flow** — alembic requires easy_flow 0.6, which counts the questions left on a flow's path.

## [0.3.0] - 2026-09-30

### Added
- **A flow's own summary page** — an owner chooses, on a flow's details page, a published page for the flow to finish on, and a visitor who finishes the flow sees that page's live blocks. A flow with no published page of its own finishes on the default summary page.
- **Blocks drawn from a run's results** — a page block type can fill an option from a value the page is drawn with, named by one of the block's fields or fixed by the block type, so a block on a summary page shows the finished run's output.
- **The note a lead carries** — a host that sets `Alembic.lead_note` to a callable taking a flow's title and its results by output id has the lead carry the note it returns. A host that sets none gets the flow's title followed by each result's label and value.
- **Fields a host adds to the lead form** — a host that sets `Alembic.lead_fields_partial` to one of its own partials has it drawn inside the lead form, so the form can carry the host's spam checks or any other field its lead address reads.
- **Result blocks** — the page builder offers blocks for a flow's score, its band with the band's description, its score per category, its weakest categories with what each one misses and costs, and the answers a visitor gave. Each result block names the output it draws in its Output field.
- **A lead block** — a host that sets `Alembic.lead_address` to a callable taking a flow's slug is offered a lead block, which posts a visitor's email with the flow's slug and a one-line result note to the path it returns. A host that sets no lead address is offered no lead block.
- **The default summary page** — a flow with no summary page of its own finishes on a page that draws its score, band, score per category and weakest categories with the result blocks, followed by the lead block when the host set a lead address.

### Changed
- **The lead partial** — `Alembic.lead_partial` no longer exists, and an app that still sets it is warned at boot to set `Alembic.lead_address` instead.
- **Results** — each summary result names the type of the output that produced it.
- **The band output** — a band output gives the band's name and description together, where it gave the name alone.
- **The weakest-categories output** — a weakest-categories output gives each category's name with the miss and cost copy its settings hold for that category, where it gave the names alone.

## [0.2.0] - 2026-09-30

### Fixed
- **Upgrading keeps flows** — moving flows onto easy_flow copies every flow, version and run into easy_flow's tables under the `alembic` host, and keeps each summary version, summary text and the summary version each run is pinned to. It used to drop them.
- **Upgrading keeps what was published** — the version a diagnostic had published becomes its live version before the link to it is dropped, so every flow still has a live version after the upgrade.

### Changed
- **Looks** — the finished page's questions, answers and dividers, the details editor's labels and back link, and the page list's labels read keystone_ui-styles' `--ks-` variables and `ks-` classes, so they follow the look, palette and dark mode a host, account or user chose.
- **Flows** — flows, their versions and their runs are easy_flow's, which Alembic now depends on at 0.4. Alembic's own copy of the flow layer, the canvas editor and their tables are gone, and a host that registered step types does so with `EasyFlow.step` in place of `Alembic::Flow.step`.
- **The flow builder** — the flow builder, the canvas and the version history are easy_flow's pages, served at the same `manage/flows` address under Alembic's mount. Links to them come from the `easy_flow` route helper in place of the `alembic` one.
- **A flow's summary text** — an author writes it on the flow's details page, since easy_flow's canvas panel does not offer it.
- **Settings** — Alembic's layout, admin layout, admin check, visitor check and refusal answer set up the easy_flow host named `alembic` and no other host, so a host keeps setting Alembic's. `Alembic.base_controller` also sets `EasyFlow.base_controller`, which easy_flow keeps for every host.
- **Refusals** — `Alembic::NotPublished`, `Alembic::NotPermitted`, `Alembic::Withdrawn` and `Alembic::OutOfService` are easy_flow's classes of the same name, so a refusal's class is named `EasyFlow::` while matching on Alembic's names still works.
- **Arranging a page** — the page builder's grid shows the page and nothing else until a designer presses Edit. Adding a block, moving one, resizing one and removing one all wait behind that, and the block types are offered in a dialog rather than beside the grid.
- **Removing a block** — a block is removed by dragging it onto the target that appears while the page is being edited, where it carried a Remove control.
- **Moving a block** — a block being edited is moved from any point on it. Holding a block for half a second starts editing, so on a touchscreen a finger that is not held scrolls the page.
- **The builder's card** — Alembic draws the card around the page builder, which the block grid drew until it stopped drawing one of its own.
- **The block grid** — Alembic takes `keystone_ui-blocks` at 0.7.0, where it took 0.2.0.

### Added
- **Flows held apart** — Alembic's flows belong to the easy_flow host named `alembic`, so an application that also holds another host's flows never lists, opens, runs or previews them on Alembic's pages. A flow made on Alembic's flow builder belongs to the `alembic` host, and code that stores a flow for Alembic names that host with `host: "alembic"`.
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
- Run `bin/rails easy_flow:install:migrations` before `bin/rails alembic:install:migrations`, then migrate. From easy_flow 0.4 this copies the migration that gives every flow a host.
- A flow stored before that migration has an empty host, so set the host of each flow Alembic runs to `alembic`.
- Alembic's migration drops `alembic_flows`, `alembic_flow_versions` and `alembic_flow_runs`, clears the summary versions that belonged to them, and keeps summary data in `alembic_flow_definition_summaries` and `alembic_flow_run_summaries`, keyed to easy_flow's tables.
- Do not mount easy_flow in the host's routes, since Alembic mounts it.
- Remove `@import "../builds/tailwind/alembic";` from `app/assets/tailwind/application.css`.
- Alembic deletes the leftover `app/assets/builds/tailwind/alembic.css` when the host app boots, so there is nothing to delete by hand.
