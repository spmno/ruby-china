class UpdateDailyHotTopicJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    # schedule test
    file = File.open("/home/sunqp/logjob.txt", 'a')
    file.puts Time.now.to_s
    file.close
    update_hot_topics
  end

  def update_hot_topics
    @hot_topic_storage = HotTopicDaily.new
    @hot_topic_storage.hot_topic_ids.clear if @hot_topic_storage.hot_topic_ids
    @hot_topic_storage.hot_topic_ids.push *topic_ids
  end

  def topic_ids
    # get hit and reply topic ids
    hit_counters = HitCounter.day_before_counters(0)
    reply_counters = Reply.day_before_counters(0)
    hot_option_topic_ids = hit_counters.map(&:topic_id) || reply_counters.map(&:topic_id)
    return nil if hot_option_topic_ids.empty?
    hot_option_topic_ids.uniq!
    hot_topic_values = {}
    hot_option_topic_ids.each do |topic_id|
      value = 0
      24.times do |i|
        hour_topic = HitCounter.hour_topic(topic_id, i).first
        hour_topic_hits = hour_topic == nil ? 0 : hour_topic.hits.value
        value += (hour_topic_hits + Reply.hour_reply(topic_id, i).size * 3) * (24 - i)
      end
      hot_topic_values[topic_id.to_s] = value
    end
    hot_topic_values.sort {|a, b| b[1]<=>a[1]}.to_h.keys
  end
end
