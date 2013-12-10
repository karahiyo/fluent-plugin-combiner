require 'helper'

class CombinerOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
  ]
  # CONFIG = %[
  #   path #{TMP_DIR}/out_file_test
  #   compress gz
  #   utc
  # ]

  def create_driver(conf = CONFIG, tag='test')
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::CombinerOutput, tag).configure(conf)
  end

  def test_configure

  end

  def test_format
    d = create_driver
  end

  def test_write
    d = create_driver
  end
end
