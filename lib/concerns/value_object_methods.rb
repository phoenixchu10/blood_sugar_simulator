require 'active_support/all'

module ValueObjectMethods
  extend ActiveSupport::Concern

  included do
    class << self
      attr_reader :all
    end
  end

  def effective_rate
    glycemic_index / self.class::DURATION
  end

  class_methods do
    def load(file_path = self::DEFAULT_FILE_PATH)
      @all = []
      CSV.foreach file_path, headers: true, converters: :numeric do |row|
        yield row
      end
    end

    def find(id)
      @indexed ||= all.index_by(&:id)
      @indexed[id]
    end
  end
end
