# frozen_string_literal: true

# Load all library files
Dir[File.join(__dir__, '..', 'lib', '**', '*.rb')].sort.each { |f| require f }