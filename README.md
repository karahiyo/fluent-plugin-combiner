# fluent-plugin-combiner

Fluentd plugin to count message keys, and make histogram.

```
$ echo '{"keys":["A",  "B",  "C",  "A"]}' | fluent-cat test.combine.input
$ echo '{"keys":["A",  "B",  "D"]}' | fluent-cat test.combine.input
```

output is

```
2013-12-17 01:06:46 +0900 combined.input: {"hist":{"A":3, "B":2, "C":1, "D":1}, "sum":7, "len":4}
```

## Configuration

```
<match test.combine.**>
    type combiner
    count_key keys                      # input message tag to count
    count_interval 5                    # count interval(second)
    tag_prefix combined                 
    input_tag_remove_prefix test.combine
</match>
```

!!`tag` parameter overwrite `tag_prefix` and `input_tag_remove_prefix`
 

## Installation

Add this line to your application's Gemfile:

    gem 'fluent-plugin-combiner'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-combiner


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
