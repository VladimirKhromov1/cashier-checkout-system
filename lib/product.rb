require_relative 'support/type_validator'

class Product
  SUPPORTED_CURRENCIES = ['GBP'].freeze

  attr_reader :code, :name, :price_in_pence, :currency

  def initialize(code:, name:, price_in_pence:, currency:)
    @code = TypeValidator.validate_string!(code, 'Product code')
    @name = TypeValidator.validate_string!(name, 'Product name')
    @price_in_pence = TypeValidator.validate_positive_integer!(price_in_pence, 'Price in pence')
    @currency = validate_currency!(currency)
    freeze
  end

  private

  def validate_currency!(currency)
    curr = TypeValidator.validate_string!(currency, 'Currency').upcase
    unless SUPPORTED_CURRENCIES.include?(curr)
      raise ArgumentError, "Unsupported currency: '#{curr}'. Supported: #{SUPPORTED_CURRENCIES.join(', ')}"
    end
    curr
  end
end