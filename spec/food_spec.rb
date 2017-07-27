describe Food do
  let(:path) { File.join(File.join File.expand_path(File.dirname(__FILE__)), 'fixtures', 'FoodDB.csv') }

  describe '.load' do
    subject { described_class.load(path) }

    it 'should be able to load all food from csv file' do
      subject
      expect(described_class.all.size).to eq 3
      food = described_class.find(1)
      expect(food.id).to eq 1
      expect(food.name).to eq 'Banana cake, made with sugar'
      expect(food.glycemic_index).to eq 47
    end
  end

  describe '.find' do
    subject { described_class.find 999 }
    before { described_class.load path }

    it 'should return nil when not found' do
      expect(subject).to be_nil
    end
  end
end
