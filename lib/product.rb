require_relative 'support/type_validator'

class Product
  SUPPORTED_CURRENCIES = ['GBP'].freeze

  attr_reader :code, :name, :amount, :currency

  def initialize(code:, name:, amount:, currency:)
    @code = TypeValidator.validate_string_field!(code, 'Product code')
    @name = TypeValidator.validate_string_field!(name, 'Product name')
    @amount = TypeValidator.validate_number_field!(amount, 'Amount')
    @currency = validate_currency!(currency)
    freeze
  end

  private

  def validate_currency!(currency)
    curr = TypeValidator.validate_string_field!(currency, 'Currency').upcase
    unless SUPPORTED_CURRENCIES.include?(curr)
      raise ArgumentError, "Unsupported currency: '#{curr}'. Supported: #{SUPPORTED_CURRENCIES.join(', ')}"
    end
    curr
  end
end