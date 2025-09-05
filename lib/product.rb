# frozen_string_literal: true

require_relative 'support/type_validator'

class Product
  SUPPORTED_CURRENCIES = ['GBP'].freeze

  attr_reader :code, :name, :amount, :currency

  def initialize(code:, name:, amount:, currency:)
    @code = TypeValidator.validate_string_field!(value: code, field_name: 'Product code')
    @name = TypeValidator.validate_string_field!(value: name, field_name: 'Product name')
    @amount = TypeValidator.validate_number_field!(value: amount, field_name: 'Amount')
    @currency = validate_currency!(currency)
    freeze
  end

  def matches?(product:)
    product.is_a?(self.class) && matches_attributes?(product)
  end

  private

  def matches_attributes?(product)
      code == product.code &&
      name == product.name &&
      amount == product.amount &&
      currency == product.currency
  end

  def validate_currency!(currency)
    curr = TypeValidator.validate_string_field!(value: currency, field_name: 'Currency').upcase
    unless SUPPORTED_CURRENCIES.include?(curr)
      raise ArgumentError, "Unsupported currency: '#{curr}'. Supported: #{SUPPORTED_CURRENCIES.join(', ')}"
    end
    curr
  end
end