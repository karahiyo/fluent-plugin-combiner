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
    f.instance.increment("a")
    expected = f.instance.flush
    assert_equal({"hist" => {"a" => 1}, "sum" => 1, "length" => 1}, expected)
  end

  def test_emit
    f = create_driver('')
    f.run do
      60.times do
        f.emit("A"); f.emit("B"); f.emit("C")
      end
    end
    out = f.instance.flush
    assert_equal({"hist" => {"A" => 60, "B" => 60, "C" => 60}, 
                  "sum" => 180, "length" => 3}, out)
  end

  def test_clear
    f = create_driver('')
    f.instance.increment("a")
    f.instance.clear
    assert_equal({"hist"=>{}, "sum" => 0, "length" => 0}, f.instance.flush)
  end
end
