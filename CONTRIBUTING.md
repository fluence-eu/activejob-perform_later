# Contributing

Thanks for contributing! Here's how to get started:

1. Open an issue to discuss the proposed change
2. Create a branch from `main`
3. Implement the change with tests
4. Make sure tests and linting pass
5. Open a pull request targeting `main`

---

## Setup

```bash
git clone git@github.com:fluence-eu/activejob-perform_later.git
cd activejob-perform_later
bundle install
```

Requires Ruby 3.2+.

## Development

### Running tests and linting

```bash
bundle exec fluence-ci all              # full catalog (lint + security + codequality + docs + tests)
bundle exec fluence-ci lint             # rubocop only
bundle exec fluence-ci tests            # minitest only
bundle exec fluence-ci docs --report    # yardstick threshold check
bundle exec rubocop -a                  # auto-fix linting (no fluence-ci equivalent)
bundle exec fluence-ci docs --build     # generate YARD HTML in doc/
```

---

## Commit Convention

This project follows [Conventional Commits](https://www.conventionalcommits.org/).

### Format

```
<type>(<scope>): <description>

[body]

[footer(s)]
```

### Types

| Type | Description |
|---|---|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only changes |
| `style` | Formatting changes (whitespace, commas, etc.) — no logic |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `perf` | Performance improvement |
| `test` | Adding or updating tests |
| `build` | Changes to build system or dependencies |
| `ci` | CI/CD configuration changes |
| `chore` | Other changes that don't modify source or tests |
| `revert` | Revert a previous commit |

### Description

- Imperative mood ("add", not "adds" or "added")
- No capital letter at the start
- No period at the end
- Maximum 72 characters

### Body (optional)

- Use bullet points with `-` for multiple items
- Explain **why**, not **what** (the diff speaks for itself)

### Breaking Changes

Non-backward-compatible changes must be flagged with:

- A `!` after the type/scope: `feat(proxy)!: change job argument format`
- And/or a `BREAKING CHANGE:` footer in the body

---

## Pull Request Convention

### PR Title

- Same format as commits: `<type>(<scope>): <description>`
- Under 72 characters

### Rules

- One topic per PR — don't mix unrelated changes
- All tests must pass (`bundle exec rake test`)
- New code must include tests
- Never commit secrets or credentials

---

## Architecture

```
lib/activejob-perform_later.rb           # Gem entry point (requires active_job + the extension)
lib/active_job/perform_later.rb          # Namespace, base_job configuration, job resolution
lib/active_job/perform_later/
  version.rb                             # Semantic version (bumped by release workflow)
  mixin.rb                               # Object#perform_later — returns the enqueueing proxy
  proxy.rb                               # BasicObject proxy capturing the next method call
  macro.rb                               # Module#perform_later_job — declares dedicated job classes
  job.rb                                 # Shared JobBehavior + generic fallback job (active_job load hook)
```

- **Mixin#perform_later** returns a **Proxy**; the next method call on it is enqueued instead of invoked
- **Macro#perform_later_job** declares per-method (optionally class/instance scoped) or class-wide job classes
- **Job resolution** walks the target's ancestry for the conventional job constant, then falls back to the generic job
- **base_job** configures the parent class of every generated job (String resolved lazily)

## Tests

- Framework: minitest (`test/**/*_test.rb`)
- All new code must be tested
- Coverage enforced at 95% minimum (SimpleCov + Undercover)
- YARD-style doc comments on all public methods

## Code Conventions

- `frozen_string_literal: true` on every Ruby file
- Strings: double quotes
- RuboCop: no rule disabling without justification
- Version in `lib/active_job/perform_later/version.rb` — do not modify unless for an explicit release
- YARD-style doc comments on all public methods

## CI

GitHub Actions:

- **main.yml** — runs on every PR: minitest across the supported Rubies
- **docs-deploy.yml** — builds the YARD site and publishes to GitHub Pages on `main`
- **docs-measure.yml**, **docs-pr.yml** — yardstick baseline on `main` + sticky coverage-delta comment on PRs
- **rubocop-measure.yml**, **rubocop-pr.yml** — RuboCop offense baseline + sticky offense-delta comment on PRs
- **coverage-measure.yml**, **coverage-pr.yml** — coverage baseline + undercover regression check
- **codequality-measure.yml**, **codequality-pr.yml** — reek/flog/flay advisory deltas
- **prepare-release.yml** — `workflow_dispatch` bump (patch/minor/major) opens an auto-merged release PR
- **release.yml** — on release PR merge, creates the tag + GitHub Release with the `.gem` attached
- **publish.yml** — on Release published, pushes the gem to GitHub Packages

---

## AI-Assisted Contributions

When using AI tools (Claude, Copilot, etc.) to generate commits or PRs:

- **Classify first** — determine if the change is critical, major, minor, or trivial
- **Focus on the "why"** — the diff already shows the "what"
- **Skip boilerplate** — don't add empty sections or placeholder text

The person opening the PR takes full responsibility for the code. Before submitting:

- [ ] I have read and understood every line of code in this PR
- [ ] I can explain why each change was made
- [ ] I have tested the changes locally

Do **not** add AI co-author lines (`Co-Authored-By`), "Generated with" footers, or any AI attribution in commits or PR descriptions.
