---
name: page-clean
description: Runs a hygiene/consistency cleanup pass on a single GEOG0030 .qmd chapter file — tidies prose, formats code chunks to match repo conventions (including aligning R code comment wording with the vocabulary used in other chapters, especially for tmap layer-by-layer map-building chunks), fixes genuine spelling mistakes, checks internal and external links, and flags heading/structure inconsistencies against the other week files. Use this whenever the user asks to "clean up", "tidy", "streamline" or "polish" a week's .qmd file, wants a consistency pass across chapters before a content rewrite, asks to check a chapter for typos or broken links, wants code comments made consistent across weeks, or wants the material "fresh" ahead of doing real content work. This is a hygiene pass only — it does NOT rewrite what a chapter teaches, restructure its pedagogy, or change explanations for style. If the user's request is actually about changing course content (what's taught, in what order, with what examples), that's a different, separate task — don't reach for this skill for that.
---

# Page clean

A chapter in this repo (any `.qmd` file, `00-index.qmd` through `11-data.qmd`) can accumulate small
rough edges over time — inconsistent chunk-option formatting, trailing whitespace, a typo in a code
comment, a link that's quietly started 404ing. This skill is a repeatable pass to sand those down
*before* anyone does the harder work of touching actual teaching content. Keeping the two separate
matters: a hygiene diff should be easy to skim and trust ("nothing here changes what's taught"), and
mixing it with content changes makes that impossible to verify at a glance.

Read `CLAUDE.md` at the repo root first if you haven't already this session — it documents standing
conventions for this repo (see "Editing conventions" and the environment/reproducibility notes) and
should stay in sync with whatever this skill treats as "the convention."

## Before touching anything

Conventions in this repo were established by the existing `.qmd` files, not by general style
preference. Before "fixing" any formatting choice, confirm it's actually inconsistent by checking
against one or two other chapters — grep for the pattern rather than assuming. A few conventions
already confirmed this way (as of 2026-08-18, cross-checked across `01-spatial.qmd`,
`02-operations.qmd`, `04-autocorrelation.qmd`):

- Code fences open with `` ```{r} `` — no trailing space.
- Chunk options in order: `label` first, then `fig-cap` immediately after it *when the chunk produces
  a figure* (before `classes`/`echo`/`eval` — confirmed across every `fig-*` chunk in `01-spatial.qmd`).
  For chunks without `fig-cap`: `label`, `classes: styled-output` (teaching chunks only), `echo`,
  `eval`, then `output`/`tidy`/`cache`/`out.width` as needed, `filename: 'R code'` last. Display-only
  image chunks (`knitr::include_graphics(...)`, `echo: False`) skip `classes` and `filename` entirely.
  One inconsistency spotted in the wild (`01-spatial.qmd`'s `fig-01-plot-map-data` chunk keeps
  `classes: styled-output` alongside `fig-cap`, unlike its siblings) — flagged to the user, who
  wasn't sure either ("might have been to make the code look better, can't remember"). Treat as
  genuinely undecided, not confirmed-intentional — still don't silently remove it on your own
  judgement, but it's fair to ask again if it recurs elsewhere rather than treating the earlier
  flag as a settled "leave it alone."
- Chunk option string values are **single-quoted** (`'100%'`, not `"100%"`) — confirmed ~180:5 in
  favour of single quotes repo-wide.
- `#| echo: True` / `False` — **capitalised `True`/`False`, deliberately, not R's own `TRUE`/`FALSE`**.
  This is a real, intentional, repo-wide convention. Never "correct" it.
- A short, lowercase, present-tense comment (`# load libraries`, `# inspect columns`) precedes
  teaching-code chunks (`echo: True`). Purely decorative/display chunks (`echo: False`,
  `knitr::include_graphics(...)`) don't get one — don't add one where the convention omits it.
- Two knitr "tidy" mechanisms coexist and need different packages to actually run:
  `` {r tidy='styler'} `` (needs `styler`) and `` #| tidy: True `` (needs `formatR`). Don't conflate
  them or "simplify" one into the other.

If you find a formatting pattern not covered above, check its prevalence across at least 2-3 other
chapters before treating it as a bug. A pattern that's genuinely everywhere (e.g. pervasive trailing
whitespace) is still worth flagging to the user as a possible separate wider pass — just don't silently
fix it repo-wide as a side effect of cleaning one file.

## The pass

Work through these in order on the target file. Use `Read` for the file itself and `Grep`/`Bash`
(`grep`, `curl`) for cross-checks — don't guess at conventions or link validity.

### 1. Prose
Read the chapter's prose fully. Fix only genuine issues: misspellings, accidental word duplication,
grammar errors, obviously broken markdown (unclosed bold/italic, malformed links). Do **not**:
rephrase working sentences for style, swap in fancier vocabulary, restructure paragraphs, or change
the author's voice. If a sentence is awkward but comprehensible and not actually wrong, leave it —
that's content-pass territory, not hygiene.

### 2. Code chunks
For every chunk, check it against the confirmed conventions above: fence formatting, option order,
quoting, `True`/`False` capitalisation, trailing whitespace, comment presence/absence. Fix
formatting only — never change what the code actually does. If you spot an apparent *logic* bug
(not a formatting issue) while reading, don't fix it silently — flag it to the user the way the
`02-operations.qmd` `d500` matrix/vector issue was flagged during this repo's last full render
(see `CLAUDE.md`'s "Known content bugs" section for that precedent). Bug fixes to actual code
behaviour deserve their own explicit sign-off, separate from a hygiene diff.

Unusual-looking but functionally valid R (e.g. an assignment like `x <- ` followed by a blank line
and a comment before the actual right-hand-side expression continues — this is legal because R keeps
reading an incomplete expression across blank lines and comments) is a style call, not a bug — flag
it as an optional observation rather than restructuring it. Confirmed example: the `lon_eurpop <- `
pattern in `01-spatial.qmd`'s last map chunk is deliberate — done so `tm_shape()` visually lines up
with the `tm_polygons()`/`tm_title()`/etc. layers underneath once rendered, a readability choice, not
an accident. Don't "fix" this pattern anywhere it recurs.

Real bugs *are* out there, though, and the first full sweep (2026-08-19) turned up several — worth
knowing the shapes they took so future passes recognise them faster:
- A second, unfixed instance of the exact same `sparse = FALSE` matrix-vs-vector bug as the `d500`
  precedent, in the same file (`02-operations.qmd`'s `d500_buffer`) — the fix (`|> as.vector()`) is
  identical, but it still needed a separate explicit sign-off, since it hadn't actually thrown an
  error yet (`count()` tolerates a matrix column in a way `if_else()` doesn't).
- A typo'd function argument name (`utlier.shape` instead of `outlier.shape` in a `geom_boxplot()`
  call, `10-datavis.qmd`) — caught by comparing against two otherwise-identical sibling chunks that
  spelled it correctly. This one *was* just fixed directly rather than flagged, since restoring a
  known, standard argument name to match its own siblings is closer to a typo fix than a design
  choice — unlike the matrix/vector bugs, which change what gets computed.
- Prose that plots the wrong object (`06-raster.qmd`: text and fig-cap both describe a *smoothed*
  raster, but the code plots the original, unsmoothed one instead of the variable it just created)
  and a leftover duplicate map layer from an apparent `tmap` v3→v4 edit that was never fully cleaned
  up (same file). Both flagged, not fixed, since they change rendered output.
- Wrong-topic copy-paste residue in prose (`09-maps.qmd`'s LSOA split/merge instructions said "total
  crimes" twice, in the *unemployment* chapter) — fixed directly, since it's unambiguously a
  terminology error, not a logic/design question.
Pattern to take from this: **matrix/vector and other silent-computation bugs get flagged, not
fixed**, because the "right" fix requires judgement about what the code should compute. **Typos in
identifiers, argument names, and prose get fixed directly**, once cross-checked against a sibling
that proves what the "correct" version looks like — there's no judgement call left once you can show
the intended form some other way.

**Comment vocabulary must match across chapters, not just within one file.** It's not enough for a
chapter to be internally consistent — the same conceptual step should use the same comment wording
everywhere it appears across the 12 chapters, especially for `tmap` layer-by-layer map-building
chunks (these show up repeatedly across weeks and are the clearest case where drift is visible to
students comparing chapters). The canonical vocabulary, established in `01-spatial.qmd`, is:

| Comment | Used for |
|---|---|
| `# shape` | a `tm_shape()` call, starting a new spatial layer |
| `# map data` | the main data layer within that shape (e.g. `tm_polygons()`, `tm_symbols()`) |
| `# legend` | legend-related parameters within a layer |
| `# borders` | border/outline parameters within a layer |
| `# title` | `tm_title()` |
| `# layout` | `tm_layout()` |
| `# North arrow` | `tm_compass()` |
| `# scale bar` | `tm_scalebar()` |
| `# centroids` | point layers derived from centroids (e.g. label anchor points) |
| `# labels` | `tm_text()` |

When cleaning any chapter with `tmap` chunks, check its layer comments against this table and align
wording to match — don't invent new phrasing for the same conceptual step just because a chapter's
existing comment technically also makes sense. This applies to comment *wording* only; never touch
what the code does. If a chapter's `tmap` code does something this table doesn't cover, extend the
table (and flag the addition to the user) rather than leaving it inconsistent or guessing.

The same principle applies to `ggplot2`-building chunks (weeks 9 and 10 especially). Canonical
vocabulary confirmed there, already consistent across every chunk in `10-datavis.qmd`:

| Comment | Used for |
|---|---|
| `# initiate ggplot` | the opening `ggplot(data = ..., aes(...))` call |
| `# add geometry` | a `geom_*()` layer |
| `# add labels` | `labs()` |
| `# add text` | `geom_treemap_text()` / `geom_treemap_subgroup_text()` or similar text layers |
| `# add border` | `geom_treemap_subgroup_border()` or similar border layers |
| `# set basic theme` | the base `theme_*()` call (e.g. `theme_light()`, `theme_minimal()`) |
| `# customise theme` | a following `theme(...)` call overriding specific elements |

### Chunk labels are also worth checking, not just comments

Several real issues found in labels during the first full sweep (2026-08-19), none of them harmless:
a label copy-pasted from a different week's file (`01-load-gpkg-csv` sitting inside
`03-point-pattern.qmd`), a label missing its week-number prefix entirely (`3-dbscan-add-clusters`
instead of `03-...`), a label with a space in it (`09-adjust weightings` — not a valid identifier
pattern), and a `fig-*`-prefixed label with the wrong week number (`fig-07-subtract-london` inside
`06-raster.qmd`). All four were safe to rename because a quick `grep -rn "<label>" *.qmd` across the
whole project confirmed nothing referenced them via `@label` — **always run that grep before
renaming a label**, since `fig-`/`tbl-` labels can be cross-referenced from anywhere in the project,
not just their own file.

**Stripping trailing whitespace**: don't reach for a bracket expression with `\t` in it —
`sed 's/[ \t]*$//'` is unsafe on BSD/macOS `sed`, where `\t` inside `[...]` is not guaranteed to be
interpreted as a tab and can instead match a literal backslash or `t`, silently eating the last
letter of any word ending in `t` (`list` → `lis`, `output` → `outpu`). This actually happened during
this skill's own first real test run. Use `sed -E 's/[[:blank:]]+$//'` (POSIX class, unambiguous)
instead, and sanity-check the regex against a short sample string before running it on the real file:
`printf 'output  \nlist   \n' | sed -E 's/[[:blank:]]+$//'` should print `output` and `list` intact.
After running any bulk find/replace across a whole file, re-`git diff` and actually read it before
declaring the pass done — don't trust that a mechanical substitution did only what you intended.

### 3. Spelling
Check spelling in both prose and code comments — comments are easy to skip and were where real typos
turned up in earlier passes. Fix only actual misspellings, not word choice.

### 4. Links
Check every link in the file:
- **External URLs**: verify with `curl -s -o /dev/null -L -w "%{http_code}" --max-time 15 "<url>"`.
  `200` is good. `403`/`417` on institutional/Microsoft-auth-gated URLs (Moodle, Outlook booking
  links) are expected, not broken — don't flag those. Publisher/DOI links (`doi.org/...`) and sites
  like `support.posit.co` also routinely return `403` to `curl` — including with a browser
  user-agent set — because of bot-walls (Cloudflare/Zendesk-style JS challenges), not because the
  link is actually dead. For `doi.org` links specifically, confirm via the DOI itself rather than the
  publisher landing page: `curl -s -o /dev/null -w "%{http_code}" "https://api.crossref.org/works/<doi>"`
  (just the `10.xxxx/...` part, no `https://doi.org/` prefix) — `200` there means the DOI is real and
  resolvable, even if curling the publisher page directly gets blocked. Anything that's a genuine
  `404`, timeout, or DNS failure — on any link — is worth surfacing. A site can also restructure
  entirely (found twice: Manuel Gimond's *Spatial* textbook renamed every chapter URL between when
  chapters were first cited and now — `chp13_0.html`/`chp16_0.html` both 404, replaced by
  `13_autocorrelation.html`/`16_interpolation.html`) — when a `404` turns up on a site that otherwise
  looks legitimate and alive, check the site's own root/nav for a working equivalent before assuming
  the resource is gone, and retarget any specific anchor fragment to the section that actually
  matches what the surrounding text describes, not just the bare page.
  The CrossRef API is also useful beyond link-checking: `https://api.crossref.org/works/<doi>` returns
  the actual author names/title/journal for a DOI, which is worth cross-checking against the citation
  text itself — found two real author-name typos this way (a missing umlaut, a Slavic surname with
  the wrong accented letter) that would never have shown up as a broken link since the DOI resolved
  fine either way.
- **Internal references**: `{{< var urls.wNN >}}`-style references resolve via `_variables.yml` —
  confirm the referenced file actually exists in the repo. `@fig-`/`@tbl-` cross-references need a
  matching `#| label: fig-...`/`tbl-...` somewhere in the project.
- Report broken links found; fix straightforward cases (typo'd URL, wrong file reference) but ask
  before changing a link's actual target if it's ambiguous which target was intended.

### 5. Structural consistency
Compare the chapter's heading structure (top-level heading, section ordering, callout usage) against
2-3 other chapters. Chapters generally follow a pattern like: title → lecture slides → reading list
→ main content sections → (assignment/before-you-leave, where applicable). Note deviations, but
**flag them rather than restructuring** — reordering sections or renaming headings changes how the
chapter reads and is closer to a content decision than a hygiene one. Surface what you found and let
the user decide.

## Output

Don't silently rewrite the file and move on. After the pass:
1. Show a concise summary of what changed and why, grouped by the five checks above (skip empty
   categories).
2. Show the actual diff (`git diff <file>`) so it can be reviewed at a glance.
3. Wait for a go-ahead before staging/committing anything — this repo's standing policy (see
   `CLAUDE.md`) is review-before-merge for anything touching the live site, and a hygiene pass is no
   exception even though the risk is low.

## Running across all chapters

This skill operates on one file per invocation. To clean the whole set, run it once per `.qmd` file
(`00-index.qmd` through `11-data.qmd`) — doing them one at a time, with a diff shown after each, keeps
each review small and means a bad call on one chapter doesn't get buried in a 12-file mega-diff.

**Commit after each chapter, not in one batch at the end** — this is the user's stated preference
(2026-08-18). Once a chapter's diff is reviewed and approved, commit it before moving on to the next
file, rather than accumulating all 12 chapters' changes into a single commit. Small per-chapter
commits are easier to review, easier to revert individually if something's wrong, and match this
repo's general standing preference for reviewable, incremental changes over large batched ones.
