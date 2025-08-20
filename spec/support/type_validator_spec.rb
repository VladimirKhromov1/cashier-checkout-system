require 'spec_helper'

RSpec.describe TypeValidator do
  describe '.validate_string!' do
    it 'returns the string when valid' do
      result = TypeValidator.validate_string!('valid_string', 'Test field')
      expect(result).to eq('valid_string')
    end

    it 'raises ArgumentError when value is not a string' do
      expect { TypeValidator.validate_string!(123, 'Test field') }
        .to raise_error(ArgumentError, 'Test field must be a String')
    end

    it 'raises ArgumentError when string is empty' do
      expect { TypeValidator.validate_string!('   ', 'Test field') }
        .to raise_error(ArgumentError, 'Test field cannot be empty')
    end
  end

  describe '.validate_positive_integer!' do
    it 'returns the integer when valid' do
      result = TypeValidator.validate_positive_integer!(42, 'Test field')
      expect(result).to eq(42)
    end

    it 'raises ArgumentError when value is not an integer' do
      expect { TypeValidator.validate_positive_integer!('42', 'Test field') }
        .to raise_error(ArgumentError, 'Test field must be an Integer')
    end

    it 'raises ArgumentError when integer is not positive' do
      expect { TypeValidator.validate_positive_integer!(0, 'Test field') }
        .to raise_error(ArgumentError, 'Test field must be positive')
    end
  end
end