class Node
  include DataMapper::Resource

  storage_names[:default] = 'v2/nodes'

  property :name, Text, :key => true
  property :deactivated, DateTime
  property :catalog_timestamp, DateTime
  property :report_timestamp, DateTime

  has n, :facts, :model => 'Fact', :child_key => [ :certname ]
  has n, :events, :model => 'Event', :child_key => [ :certname ]
  has n, :reports, :model => 'Report', :child_key => [ :certname ]

  @server_fields = [:name]
  class << self
    attr_reader :server_fields
  end
end
