class HitCounter
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel
  include Redis::Objects

  field :hit_time, type: DateTime
  field :hit_hour, type: Integer
  belongs_to :topic

  counter :hits, default: 0

  scope :hour_before_counters, ->(hour){ where(hit_time: Time.now-hour.hour-1.hour..Time.now-hour.hour) }
  scope :day_before_counters, ->(day){ where(hit_time: Time.now-day.days-1.day..Time.now-day.day) }
  scope :week_before_counters, ->(week){ where(hit_time: Time.now-week.week-1.week..Time.now-week.week) }
  scope :current_hour_topic, ->(topic){ where(hit_hour: Time.now.utc.hour, topic_id: topic) }
  scope :hour_topic, ->(topic, hour){ where(hit_hour: hour, topic_id: topic) }
  scope :day_topic, ->(topic, day) { where(hit_time: Time.now-day.days-1.day..Time.now-day.days, topic_id: topic)}

end