require 'spec_helper'

RSpec.describe Product do
  subject(:product) { described_class.new(code: code, name: name, amount: amount, currency: currency) }

  let(:code) { 'GR1' }
  let(:name) { 'Green Tea' }
  let(:amount) { 311 }
  let(:currency) { 'GBP' }

  describe '#initialize' do
    context 'with valid attributes' do
      it 'assigns all attributes correctly' do
        expect(product).to have_attributes(
          code: 'GR1',
          name: 'Green Tea',
          amount: 311,
          currency: 'GBP'
        )
      end

      context 'when the currency is lowercase' do
        let(:currency) { 'gbp' }

        it 'assigns and uppercases the currency' do
          expect(product.currency).to eq('GBP')
        end
      end

      it 'freezes the instance' do
        expect(product).to be_frozen
      end
    end

    context 'with invalid attributes' do
      context 'when the code is not a string' do
        let(:code) { 123 }
        it 'raises an ArgumentError' do
          expect { product }.to raise_error(ArgumentError, 'Product code must be a String')
        end
      end

      context 'when the name is an empty string' do
        let(:name) { '   ' }
        it 'raises an ArgumentError' do
          expect { product }.to raise_error(ArgumentError, 'Product name cannot be empty')
        end
      end

      context 'when the amount is not a positive integer' do
        let(:amount) { 0 }
        it 'raises an ArgumentError' do
          expect { product }.to raise_error(ArgumentError, 'Amount must be positive')
        end
      end
    end
  end
end