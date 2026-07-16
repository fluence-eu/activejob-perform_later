# frozen_string_literal: true

require "simplecov"
require "undercover/simplecov_formatter"

SimpleCov.start do
  add_filter "/test/"
  minimum_coverage 95
  minimum_coverage_by_file 70
  formatter SimpleCov::Formatter::MultiFormatter.new(
    [
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::Undercover
    ]
  )
end

require "cgi/escape"
require "active_job"
require "global_id"
require "activejob-perform_later"
require "minitest/autorun"

GlobalID.app = "ajpl-test"
ActiveJob::Base.queue_adapter = :test
ActiveJob::Base.logger = Logger.new(nil)
ActiveSupport.test_order = :random

require_relative "support/fixtures"

class AJPLTestCase < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TimeHelpers
end
