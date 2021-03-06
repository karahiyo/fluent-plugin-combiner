require 'helper'

class CombinerOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    count_key keys
    count_interval 5s
    tag_prefix combined
    input_tag_remove_prefix test.input
  ]

  def create_driver(conf = CONFIG, tag='test')
    Fluent::Test::OutputTestDriver.new(Fluent::CombinerOutput, tag).configure(conf)
  end

  def test_configure
    d = create_driver
    assert_equal 5, d.instance.tick
    assert_equal nil, d.instance.tag
    assert_equal 'keys', d.instance.count_key
    assert_equal 'combined', d.instance.tag_prefix
    assert_equal 'test.input', d.instance.input_tag_remove_prefix
  end

  def test_increment
    f = create_driver
    f.instance.increment("test.input", 'a')
    expected = f.instance.flush
    assert_equal({"combined" => {:hist => {"a" => 1}, :sum => 1, :len => 1}}, expected)
    expected = f.instance.flush
    assert_equal({"combined" => {:hist => {}, :sum => 0, :len => 0}}, expected)
  end

  def test_emit
    f = create_driver
    f.run do
      60.times do
        f.emit({"keys" => ["A", "B", "C"]})
      end
    end
    out = f.instance.flush
    assert_equal({"combined.test" => {:hist => {"A" => 60, "B" => 60, "C" => 60}, 
                  :sum => 180, :len => 3}}, out)
  end

  def test_flush_clear
    f = create_driver
    assert_equal({}, f.instance.counts)
    f.instance.increment("test.input", 'A')
    f.instance.flush # flush and clear counts data
    assert_equal({"combined" => {:hist => {}, :sum => 0, :len => 0}}, f.instance.flush)
  end
end
