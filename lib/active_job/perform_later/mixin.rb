# frozen_string_literal: true

module ActiveJob
  module PerformLater
    # `perform_later` entry point, mixed into Object.
    module Mixin
      # Returns a proxy that enqueues the next method call as an Active
      # Job instead of invoking it.
      #
      # @api public
      # @param options [Hash] Active Job set options (`:queue`, `:wait`,
      #   `:wait_until`, `:priority`, ...)
      # @return [Proxy] proxy enqueueing method calls on this receiver
      # @example
      #   Newsletter.perform_later(queue: :low).deliver_all
      def perform_later(**options)
        Proxy.new(self, options)
      end
    end
  end
end
