require 'json'
require 'puppet'
require 'puppet/network/http_pool'
require 'uri'

require 'dm-core'

module DataMapper
  module Adapters
    class PuppetdbAdapter < AbstractAdapter
      attr_accessor :http, :host, :port, :ssl

      def read(query)
        model = query.model

        pdbquery = build_query(query)

        results = puppetdb_get(model.storage_name(model.repository_name), pdbquery)

        query.filter_records(results)
      end

      private

      def initialize(name, options = {})
        super

        Puppet.initialize_settings unless Puppet[:confdir]

        # Set some defaults
        @host = @options[:host] || 'puppetdb'
        @port = @options[:port] || 443
        @ssl = @options[:ssl] || true
        @http = Puppet::Network::HttpPool.http_instance(@host, @port, @ssl)
      end

      ##
      # contruct a puppetdb query from a datamapper query
      def build_query(query)
        conditions = query.conditions
        if conditions.nil?
          nil
        else
           puppetdb_condition(conditions, query.model)
        end
      end

      ##
      # return puppetdb syntax for a condition
      def puppetdb_condition(c, model)
        case c
        when DataMapper::Query::Conditions::NullOperation
          nil
        when DataMapper::Query::Conditions::AbstractOperation
          q = [c.class.slug.to_s, *c.operands.map { |o| puppetdb_condition o, model }.compact]
          # In case we couldn't build any query from the contained
          # conditions return nil instead of a empty and
          return q.last if q.count == 2
          return nil if q.count < 2
          return q
        end

        # Determine the property we should match on
        if c.subject.kind_of? DataMapper::Property
          property = c.subject
        elsif c.subject.kind_of? DataMapper::Associations::Relationship
          if model == c.subject.parent_model
            property = c.subject.parent_key.first
          else
            property = c.subject.child_key.first
          end
        else
          puts "Unhandled subject #{c.subject.inspect}"
          raise RuntimeError, "Unhandled subject #{c.subject.inspect}"
        end

        # We can only do comparison on certain fields
        # on the server side
        if property.model.respond_to? :server_fields
          return nil unless property.model.server_fields.include? property.name
        end

        case c
        when DataMapper::Query::Conditions::EqualToComparison
          ['=', property.field, format_value(c.value)]
        when DataMapper::Query::Conditions::RegexpComparison
          ['~', property.field, format_value(c.value)]
        when DataMapper::Query::Conditions::LessThanComparison
          ['<', property.field, format_value(c.value)]
        when DataMapper::Query::Conditions::GreaterThanComparison
          ['>', property.field, format_value(c.value)]
        # The following comparison operators aren't supported by PuppetDB
        # So we emulate them
        when DataMapper::Query::Conditions::LikeComparison
          ['~', property.field, c.value.gsub('%', '.*')]
        when DataMapper::Query::Conditions::LessThanOrEqualToComparison
          ['or', ['=', property.field, format_value(c.value)], ['<', property.field, format_value(c.value)]]
        when DataMapper::Query::Conditions::GreaterThanOrEqualToComparison
          ['or', ['=', property.field, format_value(c.value)], ['>', property.field, format_value(c.value)]]
        when DataMapper::Query::Conditions::InclusionComparison
          if c.value.kind_of? Range
            ['or', ['=', property.field, format_value(c.value.first)], ['>', property.field, format_value(c.value.first)], ['<', property.field, format_value(c.value.last)], ['=', property.field, format_value(c.value.last)]]
          else
            ['or', *c.value.collect { |v| ['=', property.field, format_value(v.value)]} ]
          end
        end
      end

      ##
      # format a value in a query
      # especially make sure timestamps have correct format
      def format_value(value)
        if value.is_a? Date or value.is_a? Time
          value.strftime('%FT%T.%LZ')
        elsif value.is_a? DataMapper::Resource
          value.key.first
        else
          value
        end
      end

      def puppetdb_get(path, query=nil)
        uri = "/#{path}?query="
        uri += URI.escape query.to_json.to_s unless query.nil?
        resp = @http.get(uri, { "Accept" => "application/json" })
        raise RuntimeError, "PuppetDB query error: [#{resp.code}] #{resp.msg}, endpoint: #{path}, query: #{query.to_json}" unless resp.kind_of?(Net::HTTPSuccess)
        # Do a ugly hack because Hash and Array
        # properties aren't supported so we preserve them as JSON
        JSON.parse(resp.body).collect do |i|
          i.each do |k,v|
            i[k] = v.to_json if v.is_a? Hash or v.is_a? Array
          end
        end
      end
    end
  end
end
