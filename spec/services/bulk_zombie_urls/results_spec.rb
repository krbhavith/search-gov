# frozen_string_literal: true

describe BulkZombieUrls::Results do
  let(:results) { described_class.new('Test File') }

  describe '#initialize' do
    it 'initializes with correct attributes' do
      expect(results.file_name).to eq('Test File')
      expect(results.ok_count).to eq(0)
      expect(results.error_count).to eq(0)
      expect(results.updated).to eq(0)
      expect(results.errors).to be_a(Hash)
      expect(results.errors).to be_empty
    end
  end

  describe '#increment_updated' do
    it 'increments the updated count' do
      expect { results.increment_updated }.to change { results.updated }.by(1)
    end
  end

  describe '#delete_ok' do
    it 'increments the ok_count' do
      expect { results.delete_ok }.to change { results.ok_count }.by(1)
    end
  end

  describe '#add_error' do
    let(:error_message) { 'Sample error message' }
    let(:key) { 'http://example.com' }

    it 'increments the error_count' do
      expect { results.add_error(error_message, key) }.to change { results.error_count }.by(1)
    end

    it 'adds the error message to the errors hash under the correct key' do
      results.add_error(error_message, key)
      expect(results.errors[key]).to include(error_message)
    end

    it 'creates a new key in the errors hash if it does not exist' do
      expect(results.errors[key]).to be_empty
      results.add_error(error_message, key)
      expect(results.errors).to have_key(key)
    end
  end

  describe '#total_count' do
    it 'calculates the total of ok_count and error_count' do
      results.delete_ok
      results.add_error('Error message', 'key1')
      expect(results.total_count).to eq(2)
    end

    it 'returns 0 when there are no ok_count or error_count' do
      expect(results.total_count).to eq(0)
    end
  end
end
