# Cashier Checkout System

## Setup
```bash
bundle install
```

## Running Tests
```bash
bundle exec rspec
```

## Usage
```ruby
co = Checkout.new(pricing_rules)
co.scan(item)
price = co.total
```