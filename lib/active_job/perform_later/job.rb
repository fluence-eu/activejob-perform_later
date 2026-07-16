# frozen_string_literal: true

module ActiveJob
  module PerformLater
    # Shared perform implementation included in every job the gem
    # resolves or generates.
    #
    # @api private
    module JobBehavior
      # Replays the captured call: resolves a class or module reference
      # back to its constant, then public_sends the method.
      #
      # @api private
      # @param target [Object, String] receiver, or class/module name
      # @param method_name [String] method to invoke
      # @param args [Array] positional arguments
      # @param kwargs [Hash] keyword arguments
      # @return [Object] whatever the replayed method returns
      def perform(target, method_name, args, kwargs)
        target = ::Object.const_get(target) if target.is_a?(String)
        target.public_send(method_name, *args, **kwargs)
      end
    end
  end
end

ActiveSupport.on_load(:active_job) do
  # Generic fallback job used when no dedicated job constant matches the
  # enqueued method. Defined in the load hook so {PerformLater.base_job}
  # is only touched once Active Job is actually loaded.
  class ActiveJob::PerformLater::Job < ActiveJob::Base
    include ActiveJob::PerformLater::JobBehavior
  end
end
