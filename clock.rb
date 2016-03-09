require 'bundler/setup'
Bundler.require

module Clockwork
  Dog = Dogapi::Client.new(ENV.fetch('DD_API_KEY'), nil, ENV.fetch('DD_HOST'))

  handler do |job|
    Dog.batch_metrics do
      stats = Sidekiq::Stats.new

      stats.queues.each do |queue, size|
        Dog.emit_point("sidekiq.queues.#{queue}.size", size)
      end

      Dog.emit_point('sidekiq.failed', stats.failed)
      Dog.emit_point('sidekiq.enqueued', stats.enqueued)
      Dog.emit_point('sidekiq.processed', stats.processed)

      Dog.emit_point('sidekiq.processes_size', stats.processes_size)
      Dog.emit_point('sidekiq.scheduled_size', stats.scheduled_size)
      Dog.emit_point('sidekiq.retry_size', stats.retry_size)
      Dog.emit_point('sidekiq.dead_size', stats.dead_size)
      Dog.emit_point('sidekiq.workers_size', stats.workers_size)
    end
  end

  every(15.seconds, 'sidekiq')
end
