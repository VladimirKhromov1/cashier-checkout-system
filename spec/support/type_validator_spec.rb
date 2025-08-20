require 'spec_helper'

RSpec.describe TypeValidator do
  describe '.validate_string_field!' do
    subject(:validate) { described_class.validate_string_field!(value, field_name) }

    let(:field_name) { 'Test Field' }

    context 'when the string is valid' do
      let(:value) { 'valid_string' }

      it 'returns the string' do
        expect(validate).to eq('valid_string')
      end
    end

    context 'when the value is not a string' do
      let(:value) { 123 }

      it 'raises an ArgumentError' do
        expect { validate }.to raise_error(ArgumentError, 'Test Field must be a String')
      end
    end

    context 'when the string is empty or whitespace' do
      let(:value) { '   ' }

      it 'raises an ArgumentError' do
        expect { validate }.to raise_error(ArgumentError, 'Test Field cannot be empty')
      end
    end
  end

  describe '.validate_number_field!' do
    subject(:validate) { described_class.validate_number_field!(value, field_name) }

    let(:field_name) { 'Test Field' }

    context 'when the number is a valid positive integer' do
      let(:value) { 42 }

      it 'returns the integer' do
        expect(validate).to eq(42)
      end
    end

    context 'when the value is not an integer' do
      let(:value) { '42' }

      it 'raises an ArgumentError' do
        expect { validate }.to raise_error(ArgumentError, 'Test Field must be an Integer')
      end
    end

    context 'when the integer is zero' do
      let(:value) { 0 }

      it 'raises an ArgumentError for not being positive' do
        expect { validate }.to raise_error(ArgumentError, 'Test Field must be positive')
      end
    end

    context 'when the integer is negative' do
      let(:value) { -1 }

      it 'raises an ArgumentError for not being positive' do
        expect { validate }.to raise_error(ArgumentError, 'Test Field must be positive')
      end
    end
  end
end