# Spacedocs

Generate beautiful html and css for your JavaDoc'd source code.

## Installation

Add this line to your application's Gemfile:

    gem 'spacedocs'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spacedocs

## Usage

`Spacedoc.doc(output_path, source_path)` will generate html files at `output_path/docs`

If you don't feel like writing your own css

`Spacedoc.generate_css(output_path)` will generate a default stylesheet at `output_path/docs/stylesheets`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
