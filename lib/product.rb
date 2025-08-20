class Product
  attr_reader :code, :name, :price_in_pence, :currency

  def initialize(code:, name:, price_in_pence:, currency:)
    @code = code
    @name = name
    @price_in_pence = price_in_pence
    @currency = currency
  end
end