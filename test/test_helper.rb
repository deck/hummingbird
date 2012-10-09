require 'minitest/autorun'
require 'minitest/pride'
require 'hummingbird'
require 'tempfile'

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

  def path_to_fixture(name)
    File.join(FIXTURE_DIR, name)
  end

  def read_fixture(name)
    File.read path_to_fixture(name)
  end

  def copy_fixture_to(fixture, dest)
    FileUtils.cp(path_to_fixture(fixture), dest)
  end
end
