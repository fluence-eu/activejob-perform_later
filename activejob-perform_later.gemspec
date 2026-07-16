# frozen_string_literal: true

require_relative "lib/active_job/perform_later/version"

Gem::Specification.new do |spec|
  spec.name          = "activejob-perform_later"
  spec.version       = ActiveJob::PerformLater::VERSION
  spec.authors       = ["Jonathan PHILIPPE"]
  spec.summary       = "Run any method of any class in the background via Active Job"
  spec.homepage      = "https://github.com/fluence-eu/activejob-perform_later"
  spec.license       = "MIT"

  spec.metadata["allowed_push_host"] = "https://rubygems.pkg.github.com/fluence-eu"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["github_repo"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.required_ruby_version = ">= 3.2"

  spec.files         = Dir["lib/**/*.rb", "README.md", "LICENSE"]
  spec.require_paths = ["lib"]

  spec.add_dependency "activejob", ">= 7.1"
end
