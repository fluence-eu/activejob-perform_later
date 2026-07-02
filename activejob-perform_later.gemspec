# frozen_string_literal: true

require_relative "lib/active_job/perform_later/version"

Gem::Specification.new do |spec|
  spec.name          = "activejob-perform_later"
  spec.version       = ActiveJob::PerformLater::VERSION
  spec.authors       = ["Jonathan PHILIPPE"]
  spec.summary       = "Run any method of any class in the background via Active Job"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 3.2"

  spec.files         = Dir["lib/**/*.rb", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "activejob", ">= 7.1"
end
