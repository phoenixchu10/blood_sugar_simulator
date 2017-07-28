require 'active_support/all'

class Simulator
  DEFAULT_BLOOD_SUGAR = 80
  EXERCISE_DURATION = 60
  MAX_RECORD_NUMBER = 24.hours / 60

  attr_reader :blood_suguar_records, :glycation, :foods, :exercises

  def initialize
    @foods = []
    @exercises = []
    reset
  end

  def reset(start_at = 0, end_at = MAX_RECORD_NUMBER)
    @blood_suguar_records = Array.new(MAX_RECORD_NUMBER + 1, DEFAULT_BLOOD_SUGAR) if start_at == 0 and end_at == MAX_RECORD_NUMBER
    @blood_suguar_records[start_at..end_at] = Array.new(end_at - start_at + 1, DEFAULT_BLOOD_SUGAR)
    @glycation = {}
  end

  def add_food(record)
    record_number = time_to_record_number(record.keys.first)
    food = record.values.first
    foods << { record_number => food }
    reset(record_number, record_number + Food::DURATION + food.glycemic_index)
    calculate_blood_suguar(record_number, record_number + Food::DURATION + food.glycemic_index)
  end

  def calculate_blood_suguar(start_at = 0,  end_at = MAX_RECORD_NUMBER)
    foods.sort! { |food_record| food_record.keys.first }
    exercises.sort! { |exercise_record| exercise_record.keys.first }

    start_at = 0 if start_at < 0
    end_at = MAX_RECORD_NUMBER if end_at > MAX_RECORD_NUMBER

    (start_at..end_at).to_a.each.with_index do |number, index|
      if number == 0
        blood_suguar_records[number] = DEFAULT_BLOOD_SUGAR
        next
      end

      if in_food_effect? number
        effective_food_records = foods.select { |food_record| food_record.keys.first - Food::DURATION < number }
        blood_suguar_records[number] += effective_food_records.inject(0) do |sum, food_record|
          effect_duration = (duration = number - food_record.keys.first) > Food::DURATION ? Food::DURATION : duration
          sum += effect_duration * food_record.values.first.effective_rate
        end
      end

      if in_exercise_effect? number
        effective_exercise_records = exercises.select { |exercise_record| exercise_record.keys.first - EXERCISE_DURATION < number }
        blood_suguar_records[number] += effective_exercise_records.inject(0) do |sum, exercise_record|
          effect_duration = (duration = number - exercise_record.keys.first) > Exercise::DURATION ? Exercise::DURATION : duration
          sum += (number - exercise_record.keys.first) * exercise_record.values.first.effective_rate
        end
      end

      if normalized? number
        if blood_suguar_records[number - 1] > DEFAULT_BLOOD_SUGAR
          blood_suguar_records[number] = blood_suguar_records[number - 1] - 1
        elsif blood_suguar_records[number - 1] < DEFAULT_BLOOD_SUGAR
          blood_suguar_records[number] = blood_suguar_records[number - 1] + 1
        else
          blood_suguar_records[number]
        end
      end
    end
  end

  def blood_suguar_at(time)
    blood_suguar_records[time_to_record_number(time)]
  end

  private

  def time_to_record_number(time)
    raise ArgumentError, "Invalid time #{time}" unless time.include? ':'

    hour, minute = time.split(':').map(&:to_i)

    raise ArgumentError, "Invalid hour #{hour}" unless hour >= 0  && hour <= 24
    raise ArgumentError, "Invalid minute #{minute}" unless minute >= 0  && minute <= 60

    (hour.hours / 60 + minute).to_i
  end

  def in_food_effect?(record_number)
    foods.any? do |food_record|
      start_at = food_record.keys.first
      record_number > start_at && record_number <= start_at + Food::DURATION
    end
  end

  def in_exercise_effect?(record_number)
    exercises.any? do |exercise_record|
      start_at = exercise_record.keys.first
      record_number > start_at && record_number <= start_at + EXERCISE_DURATION
    end
  end

  def normalized?(record_number)
    !in_food_effect?(record_number) && !in_exercise_effect?(record_number)
  end

  def food_effect_rate(food_records)
    food_records.map { |food_record| food_record.values.first.glycemic_index }.inject(0, :+).to_f / Food::DURATION
  end

  def exercise_effect_rate(exercise_records)
    exercise_records.map { |exercise_record| exercise_record.values.first.glycemic_index }.inject(0, :+).to_f / EXERCISE_DURATION
  end
end
