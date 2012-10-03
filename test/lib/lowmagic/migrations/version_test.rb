require 'test_helper'

describe LowMagic::Migrations do
  it "defines VERSION" do
    LowMagic::Migrations::VERSION.wont_be_nil
  end
end
