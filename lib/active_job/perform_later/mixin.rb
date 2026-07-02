# frozen_string_literal: true

module ActiveJob
  module PerformLater
    module Mixin
      def perform_later(**options)
        Proxy.new(self, options)
      end
    end
  end
end
