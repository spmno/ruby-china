class HotTopicDaily
  include Redis::Objects
  list :hot_topic_ids
  def id
    1
  end
end