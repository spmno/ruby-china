class HotTopicWeekly
  include Redis::Objects
  list :hot_topic_ids
  def id
    2
  end
end