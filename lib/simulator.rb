require 'active_support/all'

class Simulator
  DEFAULT_BLOOD_SUGAR_LEVEL = 80
  FOOD_DURATION = 60 * 2

  attr_reader :blood_suguar_records, :glycation

  def initialize
    @blood_suguar_records = (1..(24.hours / 60)).to_a.inject({}) do |result, minute|
      result[minute] = DEFAULT_BLOOD_SUGAR_LEVEL
      result
    end
    @glycation = {}
  end

  def add_food(record)
    time = record.keys.first
    record_number = time_to_record_number(time)
    food = record.values.first
    (record_number..(record_number + FOOD_DURATION)).to_a.map(&:to_i).each.with_index do |number, index|
      blood_suguar_records[number] = (food.glycemic_index.to_f / FOOD_DURATION) * index + blood_suguar_records[number]
    end
  end

  def blood_suguar_at(time)
    record_number = time_to_record_number(time)
    blood_suguar_records[record_number]
  end

  private

  def time_to_record_number(time)
    raise ArgumentError, "Invalid time #{time}" unless time.include? ':'

    hour, minute = time.split(':').map(&:to_i)

    raise ArgumentError, "Invalid hour #{hour}" unless hour >= 0  && hour <= 24
    raise ArgumentError, "Invalid minute #{minute}" unless minute >= 0  && minute <= 60

    (hour.hours / 60 + minute).to_i
  end
end
