describe Simulator do
  let(:simulator) { Simulator.new }
  let(:food_path) { File.join(File.join File.expand_path(File.dirname(__FILE__)), 'fixtures', 'FoodDB.csv') }
  let(:exercise_path) { File.join(File.join File.expand_path(File.dirname(__FILE__)), 'fixtures', 'Exercise.csv') }
  let(:food) { Food.find 1 }
  let(:exercise) { Exercise.find 1 }

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
      expect(simulator.blood_suguar_at('12:30')).to be_within(1).of Simulator::DEFAULT_BLOOD_SUGAR
      expect(simulator.blood_suguar_at('13:00')).to be_within(1).of Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index / 4
      expect(simulator.blood_suguar_at('13:30')).to be_within(1).of Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index / 2
      expect(simulator.blood_suguar_at('14:30')).to be_within(1).of Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index
    end

    it 'should normalize when no eating or exercise' do
      subject
      expect(simulator.blood_suguar_at('14:30')).to be_within(1).of Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index
      expect(simulator.blood_suguar_at('14:31')).to be_within(1).of Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index - 1
      expect(simulator.blood_suguar_at("14:59")).to be_within(1).of Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index - 29
      expect(simulator.blood_suguar_at("15:16")).to be_within(1).of Simulator::DEFAULT_BLOOD_SUGAR + 1
      expect(simulator.blood_suguar_at("15:17")).to be_within(1).of Simulator::DEFAULT_BLOOD_SUGAR
    end

    context 'multiple food' do
      let(:another_food) { Food.find 2 }
      subject do
        simulator.add_food '12:00' => food
        simulator.add_food '13:00' => another_food
      end

      it 'should calcualte calculate blood suguar correctly' do
        subject
        expect(simulator.blood_suguar_at('12:00')).to be_within(1).of Simulator::DEFAULT_BLOOD_SUGAR
        expect(simulator.blood_suguar_at('13:00')).to be_within(1).of Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index / 2
        expect(simulator.blood_suguar_at('14:00')).to be_within(1).of Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index + another_food.glycemic_index / 2
        expect(simulator.blood_suguar_at('15:00')).to be_within(1).of Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index + another_food.glycemic_index
      end
    end

    context 'time span is more than 24 hours' do
      subject { simulator.add_food('23:00' => food) }

      it 'should ignore' do
        subject
        expect(simulator.blood_suguar_at('23:00')).to be_within(1).of Simulator::DEFAULT_BLOOD_SUGAR
        expect(simulator.blood_suguar_at('24:00')).to be_within(1).of Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index / 2
      end
    end
  end

  describe '#reset' do
    let(:start_at) { 145 }
    let(:end_at) { 200 }

    subject { simulator.reset(start_at, end_at) }

    before { simulator.add_food '2:20' => food }

    it 'should be able to reset certain period time to default value' do
      expect(simulator.blood_suguar_at("2:30")).to_not eq Simulator::DEFAULT_BLOOD_SUGAR

      subject

      expect(simulator.blood_suguar_at("2:30")).to be_within(1).of Simulator::DEFAULT_BLOOD_SUGAR
      expect(simulator.blood_suguar_at("3:10")).to be_within(1).of Simulator::DEFAULT_BLOOD_SUGAR
      expect(simulator.blood_suguar_at("4:20")).to_not eq Simulator::DEFAULT_BLOOD_SUGAR
      expect(simulator.blood_suguar_records.size).to eq(Simulator::MAX_RECORD_NUMBER + 1)
    end
  end

  describe 'exercise' do
    subject { simulator.add_exercise('15:30' => exercise) }

    it 'should be able to add exercise and calculate blood suguar correctly' do
      simulator.add_food '14:30' => food
      subject
      expect(simulator.blood_suguar_at('15:30')).to be_within(1).of Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index / 2
      expect(simulator.blood_suguar_at('16:00')).to be_within(1).of Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index * 0.75 + exercise.glycemic_index / 2
      expect(simulator.blood_suguar_at('16:30')).to be_within(1).of Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index + exercise.glycemic_index
    end

    it 'should be able to calculate blood suguar correctly afterwards when food overlap exercise' do
      simulator.add_food '14:45' => food
      subject
      expect(simulator.blood_suguar_at('15:30')).to be_within(1).of Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index * 3 / 8
      expect(simulator.blood_suguar_at('16:00')).to be_within(1).of Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index * 5 / 8 + exercise.glycemic_index / 2
      expect(simulator.blood_suguar_at('16:30')).to be_within(1).of Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index * 7 / 8 + exercise.glycemic_index
      expect(simulator.blood_suguar_at('16:45')).to be_within(1).of Simulator::DEFAULT_BLOOD_SUGAR + food.glycemic_index + exercise.glycemic_index
    end
  end


  it 'should be able to draw' do
  end

  it 'should be able to calcualte glycation' do
  end
end
