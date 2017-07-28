describe Simulator do
  let(:simulator) { Simulator.new }
  let(:food_path) { File.join(File.join File.expand_path(File.dirname(__FILE__)), 'fixtures', 'FoodDB.csv') }
  let(:exercise_path) { File.join(File.join File.expand_path(File.dirname(__FILE__)), 'fixtures', 'Exercise.csv') }

  before do
    Food.load(food_path)
    Exercise.load(exercise_path)
  end

  describe 'initialize' do
    it 'should keep default value' do
      subject
      expect(subject.blood_suguar_records.values.uniq).to eq [Simulator::DEFAULT_BLOOD_SUGAR_LEVEL]
      expect(subject.glycation).to eq({})
      expect(subject.blood_suguar_records.size).to eq((24.hours / 60).to_i)
    end
  end

  describe '#add_food' do
    let(:food) { Food.find(1) }
    subject { simulator.add_food('12:30' => food) }

    it 'should be able to add food' do
      subject
      expect(simulator.blood_suguar_at('12:30')).to eq Simulator::DEFAULT_BLOOD_SUGAR_LEVEL
      expect(simulator.blood_suguar_at('13:00')).to eq Simulator::DEFAULT_BLOOD_SUGAR_LEVEL + food.glycemic_index.to_f / 4
      expect(simulator.blood_suguar_at('13:30')).to eq Simulator::DEFAULT_BLOOD_SUGAR_LEVEL + food.glycemic_index.to_f / 2
      expect(simulator.blood_suguar_at('14:30')).to eq Simulator::DEFAULT_BLOOD_SUGAR_LEVEL + food.glycemic_index
    end
  end

  it 'should be able to add exercise' do
  end

  it 'should be able to draw' do
  end

  it 'should be able to calcualte glycation' do
  end
end
