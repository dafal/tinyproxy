# AGENTS.md
## Repository Overview
- This repo is a very small Ruby project centered on `tinyproxycmd.rb`.
- `tinyproxycmd.rb` parses CLI flags, writes Tinyproxy config files, prints the generated config, and starts `tinyproxy`.
- `Dockerfile` packages the script into an Alpine image.
- There is no `lib/`, `test/`, `spec/`, Gemfile, or CI workflow in the repo today.
- Ruby dependencies are stdlib only: `optparse`, `ostruct`, and `socket`.
## Files That Matter
- `tinyproxycmd.rb`: main executable and the primary place for logic changes.
- `Dockerfile`: container build and runtime behavior.
- `README.md`: usage examples and supported CLI options.
- `AGENTS.md`: instructions for coding agents operating in this repository.
## Agent Priorities
- Preserve the repo's simplicity; prefer small, direct changes over framework-heavy rewrites.
- Keep behavior obvious from reading the script.
- Favor the current single-file layout unless the task clearly benefits from refactoring.
- When changing CLI behavior, update `README.md` and `tinyproxycmd.rb --help` text together.
- Avoid introducing non-stdlib Ruby dependencies unless the user explicitly asks for them.
## Cursor And Copilot Rules
- No `.cursor/rules/` directory was found.
- No `.cursorrules` file was found.
- No `.github/copilot-instructions.md` file was found.
- If any of those files are added later, treat them as higher-priority instructions and merge their guidance into future edits.
## Build Commands
### Local Ruby Execution
- Show CLI help:
```bash
ruby tinyproxycmd.rb --help
```
- Run with temp output paths so you do not write into `/etc/tinyproxy/`:
```bash
mkdir -p /tmp/tinyproxy_test
ruby tinyproxycmd.rb \
  --config /tmp/tinyproxy_test/tinyproxy.conf \
  --config_filter /tmp/tinyproxy_test/filter \
  --user nobody \
  --group nobody \
  --timeout 600 \
  --port 8888 \
  --loglevel Info \
  --allow 127.0.0.1,::1 \
  --filter google\.com$,yahoo\.com$ \
  --no-filter_default_deny
```
### Docker Build
- Build the image:
```bash
docker build -t dafal/tinyproxy .
```
- Smoke test the image help output:
```bash
docker run --rm dafal/tinyproxy --help
```
## Lint And Validation Commands
- There is no committed lint configuration in this repo.
- Recommended ad hoc lint command if RuboCop is installed locally:
```bash
rubocop tinyproxycmd.rb
```
- Recommended auto-fix command when appropriate:
```bash
rubocop -A tinyproxycmd.rb
```
- Basic syntax validation:
```bash
ruby -c tinyproxycmd.rb
```
## Test Commands
### Current State
- There is no automated test suite checked into this repository.
- There are no `test/` or `spec/` directories, so there is currently no real single-test command to run.
- Validation is manual and should focus on CLI parsing, generated config content, and container startup.
### Recommended Manual Checks
- Help output:
```bash
ruby tinyproxycmd.rb --help
```
- Config generation with temporary files:
```bash
mkdir -p /tmp/tinyproxy_test
ruby tinyproxycmd.rb --config /tmp/tinyproxy_test/tinyproxy.conf --allow 127.0.0.1
```
- Auto-detect local networks path:
```bash
ruby tinyproxycmd.rb --config /tmp/tinyproxy_test/tinyproxy.conf --allow-local-networks
```
- Container smoke test:
```bash
docker run --rm dafal/tinyproxy --allow-local-networks --help
```
### If A Test Suite Is Added Later
- Prefer Minitest for minimal overhead unless the repo already adopts something else.
- Example single test file command:
```bash
ruby -I. test/test_tinyproxycmd.rb
```
- Example single test method command with Minitest:
```bash
ruby -I. test/test_tinyproxycmd.rb -n test_detect_local_network_subnets
```
- Example single spec file command if RSpec is introduced instead:
```bash
rspec spec/tinyproxycmd_spec.rb
```
## Coding Conventions
### Dependencies And Imports
- Keep the script compatible with a plain Ruby install plus stdlib.
- Prefer stdlib solutions before adding gems.
- Keep `require` statements at the top of the file.
- Sort `require` statements alphabetically when adding new ones unless grouping improves clarity.
### Formatting
- Use 2-space indentation.
- Avoid trailing whitespace.
- Keep most lines near 80 characters; short overflow is fine for long strings or examples.
- Leave one blank line between top-level method definitions.
- Use Unix newlines.
### Naming
- Use `snake_case` for methods, variables, and local helpers.
- Use `ALL_CAPS` for constants like `LOG_LEVELS`.
- Reserve `CamelCase` for classes or modules if they are introduced.
- Prefer explicit option names that match Tinyproxy or CLI semantics.
### Types And Data Shapes
- There is no static typing setup here.
- Keep data structures simple and predictable.
- Use arrays for ordered config entries and strings for rendered config lines.
- Keep `OpenStruct` usage shallow; prefer a small class or hash if state grows.
- Validate and normalize CLI inputs as early as possible.
### Control Flow
- Favor small helper methods for non-trivial logic such as subnet calculation or file generation.
- Prefer guard clauses over deep nesting.
- Keep option parsing readable; one option per `opts.on` block.
- Separate parsing, config rendering, and process execution when refactoring.
### Error Handling
- Rescue the narrowest exception class you can justify.
- Print actionable warnings or errors to stderr.
- Do not silently ignore failures when writing files or starting `tinyproxy`.
- If a failure should stop execution, exit non-zero or raise clearly.
- Preserve successful behavior for valid CLI inputs.
### Security And Process Execution
- Treat all CLI values as untrusted input.
- Avoid interpolated shell strings when argument-array process APIs can be used.
- Avoid writing to privileged paths in tests when a temp path works.
- Maintain the current non-root defaults unless the user asks otherwise.
### File And Config Writing
- Keep generated Tinyproxy config output deterministic.
- Preserve option order where possible so diffs stay readable.
- When writing multiple files, fail loudly if required output cannot be created.
- Avoid unnecessary quoting changes in generated config lines.
### Comments And Documentation
- Write comments only when the intent is not obvious from code.
- Prefer comments that explain why a choice exists, not what a line literally does.
- Keep README examples aligned with actual CLI behavior.
- Update help text, README, and Docker usage docs together when flags change.
## Repository-Specific Guidance
- `tinyproxycmd.rb` is both executable script and main logic module; changes here have immediate user-facing impact.
- Default paths point at `/etc/tinyproxy/`; use temporary paths for local verification.
- `Dockerfile` installs `bash`, `tinyproxy`, `curl`, and `ruby`; keep image changes minimal.
## When Making Changes
- Run `ruby -c tinyproxycmd.rb` after editing Ruby code.
- Run at least one manual CLI smoke test when behavior changes.
- If Docker behavior changes, run `docker build -t dafal/tinyproxy .` and a simple `docker run` check.
- Mention clearly in your final response if something could not be verified locally.
