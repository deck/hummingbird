require 'test_helper'

describe Hummingbird do
  it "defines VERSION" do
    Hummingbird::VERSION.wont_be_nil
  end
end
