# Rack::RequestPolice

[![Code Climate](https://codeclimate.com/github/emq/rack-request_police/badges/gpa.svg)](https://codeclimate.com/github/emq/rack-request_police)
[![Build Status](https://travis-ci.org/emq/rack-request_police.svg)](https://travis-ci.org/emq/rack-request_police)
[![Coverage Status](https://coveralls.io/repos/emq/rack-request_police/badge.svg)](https://coveralls.io/r/emq/rack-request_police)
[![Dependency Status](https://gemnasium.com/emq/rack-request_police.svg)](https://gemnasium.com/emq/rack-request_police)

Rack middleware for logging selected request for further investigation / analyze.

Features:

- filter requests by method (get/post/patch/delete) and/or regular expression
- log requests into storage of your choice (at the moment redis supported)

Work in progress.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-request_police'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-request_police

## Usage

### Rails

Add do your `application.rb` / environment config:

``` ruby
Application.configure do
  # ...
  config.middleware.use Rack::RequestPolice::Middleware
end
```

Configure middleware using initializer (eg. `config/initializers/request_police.rb`).

``` ruby
Rack::RequestPolice.configure do |config|
  # For the time being only redis storage if provided, but you can hook up
  # any storage of your choice as long it responds to log_request and page methods
  # see Storage::Base and Storage::Redis for more references
  config.storage = Rack::RequestPolice::Storage::Redis.new(host: 'localhost', port: 6379)

  # Regular expression that will be matched against request uri
  # Nil by default (logs all requests)
  config.regex = /some-url/

  # array of methods that should be logged (all four by default)
  # requests not included in this list will be ignored
  config.method = [:get, :post, :delete, :patch]
end
```

## Contributing

1. Fork it ( https://github.com/emq/rack-request_police/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
