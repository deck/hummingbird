require 'test_helper'

describe 'test_helper' do
  describe 'assert_set_equal' do
    it 'considers two empty sets equal' do
      assert_set_equal [], []
    end

    it 'considers two non-empty equal sets equal' do
      assert_set_equal [1,2,3], [1,2,3]
    end

    it 'considers a set missing members as not equal' do
      e = assert_raises MiniTest::Assertion do
        assert_set_equal [1,2,3], [1,3]
      end

      assert_equal <<-EOM, e.to_s
Expected set equality:
  Expected: [1, 2, 3]
  Actual:   [1, 3]
  Extra:    []
  Missing:  [2]
EOM
    end

    it 'considers a set with extra members as not equal' do
      e = assert_raises MiniTest::Assertion do
        assert_set_equal [1,2,3], [1,2,3,4]
      end

      assert_equal <<-EOM, e.to_s
Expected set equality:
  Expected: [1, 2, 3]
  Actual:   [1, 2, 3, 4]
  Extra:    [4]
  Missing:  []
EOM
    end
  end
end
