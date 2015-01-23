class UpdateWeeklyHotTopicJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    @file = File.open("/home/sunqp/logweeklyjob.txt", 'a')
    @file.puts Time.now.to_s
    update_hot_topics
    @file.close
  end

  def update_hot_topics
    hot_topic_storage = HotTopicWeekly.new
    hot_topic_storage.hot_topic_ids.clear if hot_topic_storage.hot_topic_ids
    ids = topic_ids
    hot_topic_storage.hot_topic_ids.push *ids if ids
  end

  def topic_ids
    hit_counters = HitCounter.week_before_counters(0)
    reply_counters = Reply.week_before_counters(0)
    hot_option_topic_ids = hit_counters.map(&:topic_id) || reply_counters.map(&:topic_id)
    return nil if hot_option_topic_ids.empty?
    hot_option_topic_ids.uniq!
    hot_topic_values = {}
    hot_option_topic_ids.each do |topic_id|
      value = 0
      7.times do |i|
        day_topic_counters = HitCounter.day_topic(topic_id, i)
        day_topic_hits = 0
        # every day hits
        unless day_topic_counters.empty?
          day_topic_counters.each do |counter|
            day_topic_hits += counter.hits.value
          end
        end
        value += (day_topic_hits + Reply.day_reply(topic_id, i).size * 3) * (7 - i)
      end
      hot_topic_values[topic_id.to_s] = value
    end
    hot_topic_values.sort {|a, b| b[1]<=>a[1]}.to_h.keys
  end

end
