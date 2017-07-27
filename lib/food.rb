require 'active_support/all'

class Food < Struct.new(:id, :name, :glycemic_index)
  DEFAULT_FILE_PATH = File.join File.expand_path(File.dirname(__FILE__)), '..', 'data', 'FoodDB.csv'

  class << self
    attr_reader :all

    def load(file_path = self::DEFAULT_FILE_PATH)
      @all = []
      CSV.foreach file_path, headers: true, converters: :numeric do |row|
        csv_values = row.to_h
        @all << new(csv_values['ID'], csv_values['Name'], csv_values['Glycemic Index'])
      end
    end

    def find(id)
      @indexed ||= all.index_by(&:id)
      @indexed[id]
    end
  end
end
