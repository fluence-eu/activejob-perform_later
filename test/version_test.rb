# frozen_string_literal: true

require "test_helper"

class VersionTest < AJPLTestCase
  test "version is defined" do
    refute_nil ActiveJob::PerformLater::VERSION
  end
end
