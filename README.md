# Fluent::Plugin::grok_pure::Parser

This fluentd parser plugin adds a parse format `grok_pure` which allows using any Grok pattern. It uses the [jls-grok](https://rubygems.org/gems/jls-grok) ruby gem, so it supports all Grok features, including type coercion.

## Installation

Install the plugin by running:

    fluent-gem install fluent-plugin-grok_pure-parser

## Usage

```
<source>
  type tail
  path /path/to/log
  tag foo.log

  format grok_pure
  grok_pattern %{HAPROXYHTTP}
  grok_pattern_path /etc/grok_patterns
</source>
```

Setting `format` to `grok_pure` enables the Grok parser. The two main configuration options are `grok_pattern_path`, which must be the path to a directory that contains grok patterns, and `grok_pattern`, which is the pattern used to match and format the record. All named grok patterns will end up as keys in the resulting record.

The following standard format options are also supported:

 - `time_key`: Sets the name of the grok capture group that contains the log timestamp
 - `time_format`: Sets the format of the log timestamp, for parsing
 - type coercion via the `TypeConverter` mixin (no official documentation available yet)

Grok patterns can generally be of the form of `%{PATTERN_NAME}`, `%{PATTERN_NAME:CAPTURE_NAME}` or `%{PATTERN_NAME:CAPTURE_NAME:type_coercion}`. See the [Logstash Grok documentation](http://logstash.net/docs/latest/filters/grok) for more details.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
