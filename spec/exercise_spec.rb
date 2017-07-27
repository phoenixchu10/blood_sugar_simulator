describe Exercise do
  let(:path) { File.join(File.join File.expand_path(File.dirname(__FILE__)), 'fixtures', 'Exercise.csv') }

  describe '.load' do
    subject { described_class.load(path) }

    it 'should be able to load all exercies from csv file' do
      subject
      expect(described_class.all.size).to eq 4
      exercise = described_class.find(1)
      expect(exercise.id).to eq 1
      expect(exercise.name).to eq 'Crunches'
      expect(exercise.glycemic_index).to eq -20
    end
  end
end
