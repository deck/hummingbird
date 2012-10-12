require 'simplecov'

SimpleCov.start do
  add_filter '/test'
end
SimpleCov.command_name 'test'

require 'minitest/autorun'
require 'minitest/pride'
require 'hummingbird'
require 'tempfile'
require 'set'

FIXTURE_DIR = File.expand_path(File.join(File.dirname(__FILE__),'fixtures'))

class MiniTest::Unit::TestCase
  def setup
    Thread.current[:minitest_hummingbird_tempfiles] = []
    Thread.current[:minitest_hummingbird_tempdirs]  = []
  end

  def teardown
    Thread.current[:minitest_hummingbird_tempfiles].each(&:unlink)
    Thread.current[:minitest_hummingbird_tempdirs].each {|d| FileUtils.remove_entry_secure(d)}
  end

  def tempfile
    f = Tempfile.new('minitest_hummingbird')
    Thread.current[:minitest_hummingbird_tempfiles] << f
    f
  end

  def tempdir
    d = Dir.mktmpdir
    Thread.current[:minitest_hummingbird_tempdirs] << d
    d
  end

  def path_to_fixture(*name)
    File.join(FIXTURE_DIR, *name)
  end

  def read_fixture(*name)
    File.read path_to_fixture(*name)
  end

  def copy_fixture_to(fixture, dest)
    FileUtils.cp(path_to_fixture(fixture), dest)
  end

  def assert_set_equal(exp, act, msg = nil)
    exp_set = exp.to_set
    act_set = act.to_set

    msg = message(msg,'') do
      m = <<-EOM
Expected set equality:
  Expected: #{mu_pp(exp)}
  Actual:   #{mu_pp(act)}
  Extra:    #{mu_pp((act_set - exp_set).to_a)}
  Missing:  #{mu_pp((exp_set - act_set).to_a)}
EOM
    end
    assert exp_set == act_set, msg
  end
end
