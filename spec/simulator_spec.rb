describe Simulator do
  let(:simulator) { Simulator.new }
  let(:food_path) { File.join(File.join File.expand_path(File.dirname(__FILE__)), 'fixtures', 'FoodDB.csv') }
  let(:exercise_path) { File.join(File.join File.expand_path(File.dirname(__FILE__)), 'fixtures', 'Exercise.csv') }
  let(:food) { Food.find 1 }

  before do
    Food.load(food_path)
    Exercise.load(exercise_path)
  end

  describe 'initialize' do
    it 'should keep default value' do
      subject
      expect(subject.blood_suguar_records.uniq).to eq [Simulator::DEFAULT_BLOOD_SUGAR]
      expect(subject.glycation).to eq({})
      expect(subject.blood_suguar_records.size).to eq(Simulator::MAX_RECORD_NUMBER + 1)
    end
  end

  describe '#add_food' do
    subject { simulator.add_food('12:30' => food) }

    it 'should be able to add food and calculate blood suguar correctly' do
      subject
      expect(simulator.foods).to eq [(12 * 60 + 30) => food]
      expect(simulator.blood_suguar_at('12:30')).to eq Simulator::DEFAULT_BLOOD_SUGAR
      expect(simulator.blood_suguar_at('13:00')).to eq Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index.to_f / 4
      expect(simulator.blood_suguar_at('13:30')).to eq Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index.to_f / 2
      expect(simulator.blood_suguar_at('14:30')).to eq Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index
    end

    it 'should normalize when no eating or exercise' do
      subject
      expect(simulator.blood_suguar_at('14:30')).to eq Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index
      expect(simulator.blood_suguar_at('14:31')).to eq Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index - 1
      expect(simulator.blood_suguar_at("14:59")).to eq Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index - 29
      expect(simulator.blood_suguar_at("15:16")).to eq Simulator::DEFAULT_BLOOD_SUGAR + 1
      expect(simulator.blood_suguar_at("15:17")).to eq Simulator::DEFAULT_BLOOD_SUGAR
    end

    context 'multiple food' do
      let(:another_food) { Food.find 2 }
      subject do
        simulator.add_food '12:00' => food
        simulator.add_food '13:00' => another_food
      end

      it 'should calcualte calculate blood suguar correctly' do
        subject
        expect(simulator.blood_suguar_at('12:00')).to eq Simulator::DEFAULT_BLOOD_SUGAR
        expect(simulator.blood_suguar_at('13:00')).to eq Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index.to_f / 2
        expect(simulator.blood_suguar_at('14:00')).to eq Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index + another_food.glycemic_index.to_f / 2
        expect(simulator.blood_suguar_at('15:00')).to eq Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index + another_food.glycemic_index
      end
    end

    context 'time span is more than 24 hours' do
      subject { simulator.add_food('23:00' => food) }

      it 'should ignore' do
        subject
        expect(simulator.blood_suguar_at('23:00')).to eq Simulator::DEFAULT_BLOOD_SUGAR
        expect(simulator.blood_suguar_at('24:00')).to eq Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index.to_f / 2
      end
    end
  end

  it 'should be able to add exercise' do
  end

  it 'should be able to draw' do
  end

  it 'should be able to calcualte glycation' do
  end
end
