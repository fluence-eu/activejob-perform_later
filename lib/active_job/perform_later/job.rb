# frozen_string_literal: true

module ActiveJob
  module PerformLater
    module JobBehavior
      def perform(target, method_name, args, kwargs)
        target = ::Object.const_get(target) if target.is_a?(String)
        target.public_send(method_name, *args, **kwargs)
      end
    end

    class Job < ActiveJob::Base
      include JobBehavior
    end
  end
end
