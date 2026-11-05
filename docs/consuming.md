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

A flow has no kind from easy_flow 0.32, which alembic requires. An app that
upgrades stops setting `kind` on a flow first, since `EasyFlow::Definition` raises
`ActiveModel::UnknownAttributeError` for it on that version. Then it takes the
new gem versions, and copies and runs easy_flow's migration in a later deploy:

```bash
$ bin/rails easy_flow:install:migrations
$ bin/rails db:migrate
```

That migration deletes each flow's stored kind. Alembic's migration that moves
flows onto easy_flow runs in either order and keeps the flows, copying the kind
only while easy_flow still stores it.

On SQLite, an app that copied `RemoveKindFromEasyFlowDefinitions` from easy_flow
0.32.0 and has not run it adds `disable_ddl_transaction!` to its copy before
running it. Run in a transaction, that copy rebuilds the flow table on SQLite and
deletes every flow's summary text, summary versions and the summary version each
run is pinned to. A copy made from easy_flow 0.32.1 or later already has the line,
and Postgres keeps these rows either way.

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
| `/alembic/manage/quizzes/new` | starting a quiz by its title, with the slug made for you |
| `/alembic/manage/flows/:id/preview` | trying a flow before it is published |
| `/alembic/manage/flows/:id/answer_key/step` | a quiz's answer key, each question with its right answer chosen |
| `/alembic/manage/pages` | the page builder |

The new quiz page asks for a title and nothing else. It answers to the same admin
check and owner as the flow builder, creates a flow of the host named `alembic`,
and goes to that flow's builder. Nothing in Alembic or easy_flow links to it, so a
host that wants it links to `alembic.new_manage_quiz_path`. easy_flow's own new
flow page at `/alembic/manage/flows/new` still asks for a slug.

The slug is made from the title:

- A title the same owner already used takes the next free number, such as
  `checkup-2`.
- A title with no usable letters or numbers takes the slug `quiz`.
- A title that makes `manage`, `pages` or `runs` takes the next free number, since
  Alembic's routes use those words.
- A very long title makes a slug cut to 100 characters, and the number of a repeated
  title goes after that. The title itself stays as typed.
- A blank title is refused on the page with an error.
- Editing the title later leaves the slug as it is.

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

The Start over link on a run's question page and its finish page leads to the
flow's intro page in Alembic. That address is the flow's public code in a host
whose easy_flow host finds flows across owners, and its slug otherwise. To send
a visitor somewhere else, set a proc that is given the flow and returns the
address:

```ruby
Alembic.start_over_address = ->(flow) { "/play/#{flow.public_code}" }
```

A proc that takes two arguments is also given the run being played, which is
nil on a page that keeps no run. Return false to hide Start over on the
question page, the one-page form and the finish page. Returning nil leaves the
link pointing at the flow's intro page in Alembic.

```ruby
Alembic.start_over_address = ->(flow, run) { run && Retakes.blocked?(run) ? false : "/play/#{flow.public_code}" }
```

The setting reaches the visitor pages only, so Start over in a preview still
returns to the preview.

A run's finish page can carry one more link, under the result, on both the
default finish page and a flow's own finish page. Set a proc that is given the
flow and returns the link's label and address:

```ruby
Alembic.finish_link = ->(flow) { { label: "See the scoreboard", url: "/play/#{flow.public_code}/scoreboard" } }
```

With the setting left unset the finish page shows no extra link. Like the Start
over address, it reaches the visitor pages only, so a preview's finish page
shows no finish link.

The default finish page's wording can be set too. Each setting is a string, and
any left unset keeps alembic's own wording:

```ruby
Alembic.finish_title = "Thanks for playing"            # default "That's everything"
Alembic.finish_subtitle = "Here is how you did"        # default "Thanks — here's what you told us"
Alembic.finish_answers_heading = "Your answers"        # default "What you told us"
```

The heading over the answers shows only when the flow has a summary, as it does
today. A flow's own finish page, built from blocks, is not changed by these.

The default finish page can draw a green Right check next to a correct answer.
It is one setting for the whole app and is off unless the app turns it on:

```ruby
Alembic.marks_right_answers = true
```

An app whose flows are quizzes turns it on. An app whose flows are scorecards
leaves it off, so its finish pages show no check. Only an answer with a positive
weight is marked right, and a multiple select or fill in the blank question is
marked right when it is answered correctly. A flow's own finish page, built from
blocks, draws no check either way.

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

When a saved run reaches its end, alembic keeps its score and its time taken
on the run's pinned summary, once. The score is the value of the first
`weighted_sum` or `inner_total` output in the pinned summary, and nothing when
it has neither. The
time taken is the whole seconds from the run's start to its last answer, kept
only for a flow that saves every answer as it is given. A flow's finished runs
come back in rank order:

```ruby
summaries.ranked             # pinned run summaries with a score, highest score first, then shortest time
summaries.ranked.first.run   # the top run; each also carries score and seconds_taken
```

A run with no time sorts after the runs with a time and the same score.

A flow whose Flow steps run other flows as inner runs, such as an event made of
quizzes, scores itself with an `inner_total` output:

```ruby
summaries.record("outputs" => [ { "id" => "total", "type" => "inner_total", "label" => "Total score" } ])
```

The total adds up the score of every inner run the saved run started, where an
inner run's score is the first `weighted_sum` or `inner_total` output in its own
pinned summary. An inner run that has not reached an End step adds nothing. The
visitor pages pin an inner run to its own flow's summary when they first reach
it, and keep its score and time once it reaches an End step, so it is ranked
with its flow's other runs. A host that starts or plays inner runs outside the
visitor pages pins them itself with `summaries.pin(run)` and keeps them with
`summaries.keep(run, state)`. Outside a saved run the total is 0.

### Output types

An output type is a pure transform:

```ruby
Alembic::Summary.output(:weighted_sum) do
  label "Score"
  compute { |config, run, so_far| ... }
end
```

- `config` — the output's own entry from the summary document
- `run` — a `Summary::Run`, holding `state`, the step definitions and, for a
  saved run, the `EasyFlow::Run` itself as `run.run`
- `so_far` — outputs already computed this pass, keyed by id, so an output can
  build on an earlier one

Outputs are computed in document order, which is what lets `band` read the
score that `weighted_sum` just produced. `run.state` holds what was answered and
`run.step(id)` holds the step's config.

Each result is a `Summary::Result` with an `id`, a `label` and a `value`. The
label falls back to the output type's own label when the document does not
give one. An unknown type raises `Summary::UnknownOutputType`.

Seven output types ship built in:

| Type | Config | Value |
|---|---|---|
| `weighted_sum` | — | sum of the chosen answers' weights |
| `percentage` | — | that sum as a share of the maximum reachable on the path taken |
| `grouped` | `by` (defaults to the step's `category`) | `{ category => percentage }` for each category answered |
| `lowest` | `of`, `count` (default 1) | the weakest categories from a `grouped` output |
| `tally` | `tag`, `by` (defaults to the step's `category`) | how many steps were answered, optionally for one category |
| `band` | `of`, `bands` | the first band whose `ceiling` the value falls under |
| `inner_total` | — | sum of the scores of the inner runs that reached an End step |

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

A flow's details page can set it to show each question's answers in a random
order. Each visitor's order comes from their run, or from a cookie when the flow
keeps no run, so it stays the same for them. The preview and the answer key keep
the built order.

An admin tries a flow at `/alembic/manage/flows/:id/preview`. It runs the flow
as it is being edited, finishes on the same summary page a visitor sees, and is
authenticated as the rest of the builder is.

The answer key at `/alembic/manage/flows/:id/answer_key/step` steps through the
same preview with each question's right answer already chosen: the option
carrying points on a single-choice question, every option carrying points on a
multiple-select question, and the first accepted answer on a fill-in-the-blank
question. Under each question a green Right answer badge names that answer, and
on a fill-in-the-blank question it names every accepted answer, joined with "or".
It saves no run, opens only the owner's flows, and the flow's details page links
to it. A host links to it with
`alembic.step_manage_flow_answer_key_path(flow)`.

## 5. Uploading questions from a CSV file

A builder can upload a CSV file of questions into a quiz from the quiz's details
page. Alembic offers this through [ixport](https://github.com/DYB-Development/ixport),
which the host adds itself. Alembic does not depend on ixport: its question
importer and the "Upload questions" link exist only in a host that has it.

Add ixport, and wallflower to run uploads in the background, then install their
tables and mount both:

```ruby
gem "ixport", "~> 0.4"
gem "wallflower"
```

```bash
$ bin/rails generate wallflower:install
$ bin/rails generate ixport:install
$ bin/rails db:migrate
```

```ruby
mount Ixport::Engine => "/imports"
mount Wallflower::Engine => "/background"
```

Configure ixport, and register Alembic's importer with `refuse_whole_file: true`
and its owner check:

```ruby
# config/initializers/ixport.rb
Ixport.configure do |config|
  config.current_account_method = :current_owner
  config.background_runner = :wallflower
end

Ixport.register_import :quiz_questions, title: "Quiz questions", importer: "Alembic::QuestionImporter",
  refuse_whole_file: true,
  allow: ->(_person, account, quiz) { Alembic::QuestionImporter.allows?(account, quiz) }
```

When `Alembic.owner_method` is set, `config.current_account_method` names the
same method. The rule then refuses any quiz that does not belong to the current
owner, and the upload pages answer not found for it. With no owner method set,
the rule allows any of Alembic's flows. ixport's views use keystone_ui's
helpers, so the controller ixport's pages inherit has to offer them.

The upload page lists the fields a file's columns are matched to, and the
builder matches each column on the next page:

| Field | What it holds |
|---|---|
| Type | `True/false` or `Multiple choice` |
| Question | the question's text |
| Category | the question's category, which may be blank |
| Answer 1 to Answer 6 | a multiple choice question's answers, at least two |
| Right answer | the number of the right answer, or `true` or `false` for a true/false question |

Each row becomes a question step, added after the quiz's last question in its
working draft, with weight 1 on the right answer and 0 on the others. Takers see
the new questions once the builder publishes the quiz. A file in which any row
cannot become a question saves nothing, and the preview names each such row
with what is wrong with it.
