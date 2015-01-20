class UpdateDailyHotTopicJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
  end
end
