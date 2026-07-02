# frozen_string_literal: true

class TestService
  RESULTS = []

  def self.build(label, count = 1, upcase: false)
    value = upcase ? label.upcase : label
    RESULTS << [value, count]
    value
  end

  class << self
    private def internal_cleanup; end
  end
end
