require_relative 'support/type_validator'

class Product
  SUPPORTED_CURRENCIES = ['GBP'].freeze

  attr_reader :code, :name, :price_in_pence, :currency

  def initialize(code:, name:, price_in_pence:, currency:)
    @code = TypeValidator.validate_string_field!(code, 'Product code')
    @name = TypeValidator.validate_string_field!(name, 'Product name')
    @price_in_pence = TypeValidator.validate_number_field!(price_in_pence, 'Price in pence')
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