require 'helper'

class CombinerOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
  ]

  def create_driver(conf = CONFIG, tag='test')
    Fluent::Test::OutputTestDriver.new(Fluent::CombinerOutput, tag).configure(conf)
  end

  def test_configure
    f = create_driver('')
  end

  def test_increment
    f = create_driver('')
    f.instance.increment("test.input", 'a')
    expected = f.instance.flush
    assert_equal({"combined.test.input" => {:hist => {"a" => 1}, :sum => 1, :len => 1}}, expected)
    expected = f.instance.flush
    assert_equal({"combined.test.input" => {:hist => {}, :sum => 0, :len => 0}}, expected)
  end

  def test_emit
    f = create_driver('')
    f.run do
      60.times do
        f.emit({"keys" => ["A", "B", "C"]})
      end
    end
    out = f.instance.flush
    assert_equal({"combined.test" => {:hist => {"A" => 60, "B" => 60, "C" => 60}, 
                  :sum => 180, :len => 3}}, out)
  end

  def test_clear
    f = create_driver('')
    assert_equal({}, f.instance.hist)
    f.instance.increment("test.input", 'A')
    f.instance.clear
    assert_equal({"combined.test.input" => {:hist => {}, :sum => 0, :len => 0}}, f.instance.flush)
  end
end
