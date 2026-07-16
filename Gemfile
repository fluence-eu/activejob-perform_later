# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "minitest"
gem "rake"

# Curated dev/CI tooling — pulls in rubocop, reek, flog, flay, yard,
# yardstick, simplecov, undercover (and brakeman + bundler-audit +
# ruby_audit which a pure gem doesn't actually invoke but the install
# overhead is negligible). All pins live in the meta-gem; bumping a
# tool here is `bundle update fluence-ci-tools`.
# https://github.com/fluence-eu/fluence-ci-tools
source "https://rubygems.pkg.github.com/fluence-eu" do
  gem "fluence-ci-tools", require: false
end
