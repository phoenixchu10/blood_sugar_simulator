class Food < Struct.new(:id, :name, :glycemic_index)
  include RecordMethods

  DURATION = 60 * 2

  DEFAULT_FILE_PATH = File.join File.expand_path(File.dirname(__FILE__)), '..', 'data', 'FoodDB.csv'

  def self.load(file_path = DEFAULT_FILE_PATH)
    super do |row|
      csv_values = row.to_h
      @all << new(csv_values['ID'], csv_values['Name'], csv_values['Glycemic Index'].to_f)
    end
  end
end
