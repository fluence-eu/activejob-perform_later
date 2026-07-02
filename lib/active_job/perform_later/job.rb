# frozen_string_literal: true

module ActiveJob
  module PerformLater
    module JobBehavior
      def perform(target, method_name, args, kwargs)
        target = ::Object.const_get(target) if target.is_a?(String)
        target.public_send(method_name, *args, **kwargs)
      end
    end
  end
end

ActiveSupport.on_load(:active_job) do
  class ActiveJob::PerformLater::Job < ActiveJob::Base
    include ActiveJob::PerformLater::JobBehavior
  end
end
