# Consuming Alembic

Alembic builds diagnostics on top of [easy_flow](https://github.com/DYB-Development/easy_flow).
easy_flow owns the flow layer: the flow document, step types, runs, versions,
validation, the canvas editor, and the visitor and admin pages. Its README
documents that interface, and a host registers step types with `EasyFlow.step`
and a drawing template with `EasyFlow.draws_with`.

Alembic adds what makes a flow a diagnostic: a summary that works out outputs
from a finished run, a summary text shown under a flow's title, and the pages
a visitor sees at the start and at the end. This document covers those, and the
settings a host gives Alembic.

## 1. Installing

Alembic's tables refer to easy_flow's, so easy_flow's migrations are installed
first:

```bash
$ bin/rails easy_flow:install:migrations
$ bin/rails alembic:install:migrations
$ bin/rails db:migrate
```

easy_flow's migrations give every flow a host. Alembic's flows belong to the
host named `alembic`, so code that stores a flow for Alembic names it:

```ruby
EasyFlow::Definition.upsert_definition(definition, host: "alembic")
```

A flow of another host is never listed, opened, run or previewed on Alembic's
pages.

Mount Alembic and nothing else. Alembic mounts easy_flow's admin pages inside
its own routes, so a host does not mount easy_flow itself for Alembic:

```ruby
mount Alembic::Engine => "/alembic"
```

| Address | What it serves |
|---|---|
| `/alembic/:slug` | a flow's intro page |
| `/alembic/:slug/step` | a flow walked without saving a run |
| `/alembic/:slug/runs` | starts a saved run |
| `/alembic/runs/:id` | a saved run |
| `/alembic/pages/:slug` | a published page |
| `/alembic/manage/flows` | easy_flow's flow builder |
| `/alembic/manage/flows/:id/edit` | a flow's details, with its summary text |
| `/alembic/manage/flows/:id/preview` | trying a flow before it is published |
| `/alembic/manage/pages` | the page builder |

## 2. Settings

A host sets Alembic's settings. The layout, the admin layout, the admin check,
the visitor check and the refusal answer set up the easy_flow host named
`alembic`, which serves Alembic's flow pages, and reach no other host.
`Alembic.base_controller` also sets `EasyFlow.base_controller`, which easy_flow
keeps for every host:

```ruby
# config/initializers/alembic.rb
Alembic.base_controller = "ApplicationController"
Alembic.layout = "application"
Alembic.admin_layout = "admin"
Alembic.admin_authentication_method = :require_admin
Alembic.visitor_authorization_method = :alembic_visitor_permitted?
Alembic.refusal_method = :alembic_refused
```

`Alembic.base_controller` has to be set before any flow page is loaded, which an
initializer does.

## 3. Summarising

A flow's summary is a list of outputs, recorded as numbered versions:

```ruby
summaries = Alembic::Flow::Summaries.new(flow)   # flow is an EasyFlow::Definition

summaries.record("outputs" => [
  { "id" => "score", "type" => "weighted_sum", "label" => "Your score" },
  { "id" => "band",  "type" => "band", "of" => "score",
    "bands" => [ { "ceiling" => 10, "name" => "Getting started" }, { "name" => "Strong" } ] }
])

summaries.document         # the summary at the flow's summary cursor
summaries.of(state)        # the outputs for a hash of step id to answer
summaries.describe("What this asks about")
summaries.text             # the summary text shown under the flow's title
```

A saved run is pinned to the summary version its flow was on when the run
started, or when it finished for a flow that keeps a run only at the end. A
newer summary does not change what an earlier run shows:

```ruby
summaries.pin(run)
summaries.pinned_to(run)     # the pinned summary version, or nil
summaries.of_run(run, state) # the outputs from the pinned summary and the run's pinned steps
```

The finished page shows each output as a card above the answers given.

### Output types

An output type is a pure transform:

```ruby
Alembic::Summary.output(:weighted_sum) do
  label "Score"
  compute { |config, run, so_far| ... }
end
```

- `config` — the output's own entry from the summary document
- `run` — a `Summary::Run`, holding `state` and the step definitions
- `so_far` — outputs already computed this pass, keyed by id, so an output can
  build on an earlier one

Outputs are computed in document order, which is what lets `band` read the
score that `weighted_sum` just produced. `run.state` holds what was answered and
`run.step(id)` holds the step's config.

Each result is a `Summary::Result` with an `id`, a `label` and a `value`. The
label falls back to the output type's own label when the document does not
give one. An unknown type raises `Summary::UnknownOutputType`.

Six output types ship built in:

| Type | Config | Value |
|---|---|---|
| `weighted_sum` | — | sum of the chosen answers' weights |
| `percentage` | — | that sum as a share of the maximum reachable on the path taken |
| `grouped` | `by` (defaults to the step's `category`) | `{ category => percentage }` for each category answered |
| `lowest` | `of`, `count` (default 1) | the weakest categories from a `grouped` output |
| `tally` | `tag`, `by` (defaults to the step's `category`) | how many steps were answered, optionally for one category |
| `band` | `of`, `bands` | the first band whose `ceiling` the value falls under |

A band with no `ceiling` is the catch-all. The weights and categories come from
easy_flow's question step, which carries `weight` on each answer and a
`category` on the step.

## 4. Deciding who may see a flow

A flow is closed until the host says otherwise. Name a method on the base
controller and it is asked before every visitor request:

```ruby
class ApplicationController < ActionController::Base
  def alembic_visitor_permitted?(flow)
    current_user&.entitled_to?(flow.slug)
  end
end
```

Configure nothing and every flow is closed.

### The refusals

| Error | Meaning |
|---|---|
| `Alembic::NotPublished` | The flow or page has no live version. |
| `Alembic::NotPermitted` | The flow is live, but not for this visitor, or it is inactive. |
| `Alembic::Withdrawn` | The version this run was part way through was withdrawn. |

Each is the same class as easy_flow's error of the same name, so a host matching
on Alembic's names matches refusals from flows and from pages.

Configure nothing and all three render a plain `404`. To answer a refusal
another way, name a method and it is handed the refusal:

```ruby
class ApplicationController < ActionController::Base
  def alembic_refused(refusal)
    return head :not_found if refusal.is_a?(Alembic::NotPublished)

    redirect_to login_path
  end
end
```

Do not use `rescue_from` for this. The engine's controllers inherit from the
host's base controller, so a handler registered there is shadowed by the
engine's own.

### Previewing what visitors cannot reach

An admin tries a flow at `/alembic/manage/flows/:id/preview`. It runs the flow
as it is being edited, finishes on the same summary page a visitor sees, and is
authenticated as the rest of the builder is.
