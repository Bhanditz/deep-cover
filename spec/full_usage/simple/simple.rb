# frozen_string_literal: true
require 'bundler/setup'

begin
  # __FILE__ can be a relative path. Since we change the current dir for the test,
  # need to track the absolute path instead.
  absolute_file = File.absolute_path(__FILE__)
  absolute_dir = File.dirname(absolute_file)
  Dir.chdir(absolute_dir)

  # A list of file that were executed
  $executed_files = []

  $LOAD_PATH << absolute_dir

  def fail_test(msg, exception=nil)
    puts(msg)
    puts("#{exception.class}: #{exception}\n#{exception.backtrace.join("\n")}") if exception
    exit(1)
  end

  def test_require(require_path, expected_value = true, detail=nil)
    value = require require_path
    if value != expected_value
      fail_test "Expected return of #{detail}`require #{require_path.inspect}` to be #{expected_value.inspect}, got: #{value.inspect}"
    end
    test_require(require_path, false, 'repeated ') if expected_value == true
  end

  # Load deep_cover
  $LOAD_PATH << File.absolute_path('../../../lib', absolute_dir)
  if ARGV[0] == 'takeover'
    require 'deep_cover/builtin_takeover'
    Coverage.start
  elsif ARGV[0].nil?
    require 'deep_cover'
    DeepCover.start
  else
    raise "Unsupported ARGV[0]: #{ARGV[0].inspect}"
  end

  test_require('beside_simple')
  test_require('./relative_beside_simple')
  test_require('subdir/deeper')
  autoload :ToAutoload, 'from_autoload'
  _foo = ::ToAutoload

  expected_executed_files = %w(beside_simple.rb relative_beside_simple.rb deeper.rb from_autoload.rb)
  if $executed_files != expected_executed_files
    fail_test "Executed files don't match the expectation:\nExpected: #{expected_executed_files}\nGot:      #{$executed_files}"
  end



  begin
    require 'that_is_missing_huh'
  rescue LoadError
    # expected
  rescue => e
    fail_test "Running `require 'that_is_missing_huh'` should have raised LoadError but instead raised:", e
  else
    fail_test "Running `require 'that_is_missing_huh'` should have raised but didn't"
  end

rescue Exception => e
  fail_test("Uncaught exception during test:", e)
end

puts("Done")
