class Record
  attr_reader :time, :obj, :number

  def self.time_to_record_number(time)
    raise ArgumentError, "Invalid time #{time}" unless time.include? ':'

    hour, minute = time.split(':').map(&:to_i)

    raise ArgumentError, "Invalid hour #{hour}" unless hour >= 0  && hour <= 24
    raise ArgumentError, "Invalid minute #{minute}" unless minute >= 0  && minute <= 60

    (hour.hours / 60 + minute).to_i
  end

  def initialize(hash)
    @time = hash.keys.first
    @obj = hash.values.first
    @number = self.class.time_to_record_number(@time)
  end

  def ==(other)
    self.class == other.class &&
    number == other.number &&
    obj == other.obj
  end
  alias :eql? :==
end
