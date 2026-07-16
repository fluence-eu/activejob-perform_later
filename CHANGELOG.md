# Changelog

All notable changes to this project will be documented in this file.
## [Unreleased]

### Build

- build: add fluence-ci-tools tooling and gem metadata

### CI

- ci: wire fluence-eu/ci-workflows@v6 gates and release flow

### Documentation

- docs: add changelog and contributing guide
- docs: document the public API and wire the yardstick gate

### Style

- style: add rubocop config aligned with the existing code style

### Tests

- test: enforce coverage thresholds with SimpleCov and Undercover

## [0.1.0] - 2026-07-02

### Added

- Add MIT license
- Add README
- Add on: scope to per-method jobs
- Add per-method perform_later_job
- Add perform_later_job class-level macro
- Add universal perform_later proxy for class methods
- Add gem scaffolding

### Other

- Trim unused DualRecord fixture code
- Cover class call ignoring instance-scoped job
- Defer generic job definition to the active_job load hook
- Reject blocks passed to proxied calls
- Document macro ordering and proxy forwarding
- Reject String targets with a clear error
- Make proxy inspect safe for consoles
- Make the generated jobs base class configurable
- Cover top-level constant anti-leak in job resolution
- Make vanished-class test cleanup exception-safe
- Lock fail-fast error contracts
- Lock enqueue options passthrough contract
- Cover module and GlobalID instance targets
- Use cgi/escape to avoid Ruby 4 CGI deprecation warning

