# More info at https://github.com/guard/guard#readme

guard 'minitest' do
  # with Minitest::Unit
  watch(/^test\/(.*)\/?(.*)_test\.rb/)
  watch(/^(lib\/.*)([^\/]+)\.rb/)      { |m| "test/#{m[1]}#{m[2]}_test.rb" }
  watch(/^test\/test_helper\.rb/)      { "test" }
end
