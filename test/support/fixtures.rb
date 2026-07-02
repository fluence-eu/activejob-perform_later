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

module TestModule
  RESULTS = []

  def self.cleanup(name)
    RESULTS << name
  end
end

class TestRecord
  include GlobalID::Identification

  REGISTRY = {}
  RESULTS = []

  attr_reader :id

  def self.find(id)
    REGISTRY.fetch(id.to_i)
  end

  def initialize(id)
    @id = id
    REGISTRY[id.to_i] = self
  end

  def touch(note = nil, force: false)
    RESULTS << [id, note, force]
  end
end
