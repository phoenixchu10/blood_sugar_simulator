require 'active_support/all'

class Simulator
  DEFAULT_BLOOD_SUGAR = 80
  MAX_RECORD_NUMBER = 24.hours / 60
  GLYCATION_LIMIT = 150

  attr_reader :blood_suguar_records, :glycation, :foods, :exercises

  def initialize
    @foods = []
    @exercises = []
    reset
  end

  def reset(start_at = 0, end_at = MAX_RECORD_NUMBER)
    if start_at == 0 and end_at == MAX_RECORD_NUMBER
      @blood_suguar_records = Array.new(MAX_RECORD_NUMBER + 1, DEFAULT_BLOOD_SUGAR)
      @glycation = Array.new(MAX_RECORD_NUMBER + 1, 0)
      return
    end
    @blood_suguar_records[start_at..end_at] = Array.new(end_at - start_at + 1, DEFAULT_BLOOD_SUGAR)
    @glycation[start_at..end_at] = Array.new(end_at - start_at + 1, 0)
  end

  def add_food(record)
    record_number = time_to_record_number(record.keys.first)
    food = record.values.first
    foods << { record_number => food }
    reset record_number
    calculate_blood_suguar record_number
  end

  def add_exercise(record)
    record_number = time_to_record_number(record.keys.first)
    exercise = record.values.first
    exercises << { record_number => exercise }
    reset record_number
    calculate_blood_suguar record_number
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

      effective_food_records = foods.select { |food_record| number - food_record.keys.first < Food::DURATION }
      effective_exercise_records = exercises.select { |exercise_record| number - exercise_record.keys.first < Exercise::DURATION }

      blood_suguar_records[number] = blood_suguar_records[number - 1] +
        effective_food_records.map { |food_record| food_record.values.first.effective_rate }.inject(0, :+) +
        effective_exercise_records.map { |exercise_record| exercise_record.values.first.effective_rate }.inject(0, :+)

      if normalized? number
        if blood_suguar_records[number - 1] > DEFAULT_BLOOD_SUGAR
          blood_suguar_records[number] = blood_suguar_records[number - 1] - 1
        elsif blood_suguar_records[number - 1] < DEFAULT_BLOOD_SUGAR
          blood_suguar_records[number] = blood_suguar_records[number - 1] + 1
        else
          blood_suguar_records[number]
        end
      end

      if blood_suguar_records[number] > GLYCATION_LIMIT
        glycation[number] = 1
      end
    end
  end

  def blood_suguar_at(time)
    blood_suguar_records[time_to_record_number(time)]
  end

  def total_glycation
    glycation.select { |value| value > 0 }.size
  end

  def print_result
    blood_suguar_records.map.with_index do |value, index|
      { "#{index/60}:#{index%60}" => value }
    end
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
      record_number > start_at && record_number <= start_at + Exercise::DURATION
    end
  end

  def normalized?(record_number)
    !in_food_effect?(record_number) && !in_exercise_effect?(record_number)
  end

  def food_effect_rate(food_records)
    food_records.map { |food_record| food_record.values.first.glycemic_index }.inject(0, :+) / Food::DURATION
  end

  def exercise_effect_rate(exercise_records)
    exercise_records.map { |exercise_record| exercise_record.values.first.glycemic_index }.inject(0, :+) / Exercise::DURATION
  end
end
