# Cashier Checkout System

> Flexible checkout system for a supermarket chain

## Requirements

- **Ruby**: >= 3.2.0
- **Bundler**: >= 2.7.1

## Quick Start

### 1. Clone and Install
```bash
git clone <repository-url>
cd cashier-checkout-system
bundle install
```

### 2. Verify Assignment
```bash
# Run all assignment test cases
rake verify_assignment

# Run all tests with coverage report
bundle exec rspec --format documentation
```

## Assignment

### Registered Products
| Code | Name | Price |
|------|------|-------|
| GR1 | Green tea | £3.11 |
| SR1 | Strawberries | £5.00 |
| CF1 | Coffee | £11.23 |

### Special Conditions
- **CEO**: Buy-one-get-one-free for green tea (GR1)
- **COO**: Bulk discount for strawberries (SR1) - 3+ items at £4.50 each
- **CTO**: Coffee discount (CF1) - 3+ items drop to 2/3 of original price

### Interface
```ruby
co = Checkout.new(discount_rules: discount_rules)
co.scan(product: item)
co.scan(product: item)
price = co.total
```

### Test Cases
```
Basket: GR1,SR1,GR1,GR1,CF1 => £22.45
Basket: GR1,GR1 => £3.11
Basket: SR1,SR1,GR1,SR1 => £16.61
Basket: GR1,CF1,SR1,CF1,CF1 => £30.57
```

## Usage Example

```ruby
require_relative 'lib/checkout'
require_relative 'lib/catalog'
require_relative 'lib/discount_rules/buy_one_get_one_free'
require_relative 'lib/discount_rules/bulk_discount'
require_relative 'lib/discount_rules/fractional_discount'

# Setup discount rules
discount_rules = [
  DiscountRules::BuyOneGetOneFree.new(product_code: 'GR1'),
  DiscountRules::BulkDiscount.new(product_code: 'SR1', required_quantity: 3, discounted_amount: 450),
  DiscountRules::FractionalDiscount.new(product_code: 'CF1', required_quantity: 3, numerator: 2, denominator: 3)
]

# Create checkout
co = Checkout.new(discount_rules: discount_rules)

# Find products in catalog
green_tea = Catalog.find_product(product_code: 'GR1')

# Scan 2 green teas
2.times { co.scan(product: green_tea) }

# Get total
price = co.total  # "£3.11"
```

## Technical Details

- **RSpec**: testing framework with full test coverage
- **No external database**: uses in-memory catalog
- **No Rails**: pure Ruby implementation
- **TDD approach**: test-driven development