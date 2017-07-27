require 'active_support/all'
require 'concerns/value_object_methods'

class Exercise < Struct.new(:id, :name, :glycemic_index)
  include ValueObjectMethods

  DEFAULT_FILE_PATH = File.join File.expand_path(File.dirname(__FILE__)), '..', 'data', 'Exercise.csv'

  def self.load(file_path = self::DEFAULT_FILE_PATH)
    super do |row|
      csv_values = row.to_h
      @all << new(csv_values['ID'], csv_values['Exercise'], -csv_values['Exercise Index'])
    end
  end
end