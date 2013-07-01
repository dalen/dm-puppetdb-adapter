# DataMapper PuppetDB Adapter

## Install

Requirements:

* json
* puppet 3.x
* dm-types

    gem install dm-puppetdb-adapter

## Usage

It will use the puppet configuration of the user it runs under, so make sure it has a SSL certificate that can connect to your PuppetDB instace.

To setup the adapter:

    DataMapper.setup(:default, {
      :adapter => 'puppetdb',
      :host => 'puppetdb.example.com',
      :port => 8081,
      :ssl => true,
    })

Or if you use it under `dm-rails` add this to `config/database.yml`:

    defaults: &defaults
      adapter: puppetdb
      host: 'puppetdb.example.com'
      port: 8081
      ssl: true

    development:
      <<: *defaults

    test:
      <<: *defaults

    production:
      <<: *defaults

To include all predefined PuppetDB models add this:

    require "dm-puppetdb-adapter/models"

Queries like `Node.all(:name.like => '%.example.com')` etc should then work. See the models and DataMapper documentation for more info on query syntax.

## Notes

* It handles subqueries by doing multiple queries to PuppetDB, so it doesn't have optimal performance for them.
* There's no select method implemented on the adapter for doing manual queries yet.
* PuppetDB can only search for some fields server side, so the other fields are filtered client side, but all of them work filtering against. Same goes for limits and offsets.
