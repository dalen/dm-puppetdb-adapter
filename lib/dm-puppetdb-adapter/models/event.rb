class Event
  include DataMapper::Resource

  storage_names[:default] = 'experimental/events'

  property :old_value, Text, :field => 'old-value'
  property :new_value, Text, :field => 'new-value'
  property :property, String, :length => 40, :key => true
  property :message, Text
  property :status, String, :length => 40
  property :timestamp, DateTime
  property :resource_type, Text, :field => 'resource-type', :key => true
  property :resource_title, Text, :field => 'resource-title', :key => true

  belongs_to :node, :model => 'Node', :child_key => :certname
  belongs_to :report, :model => 'Report', :key => true

  @server_fields = [
    :certname,
    :report,
    :status,
    :timestamp,
    :resource_type,
    :resource_title,
    :property,
    :new_value,
    :old_value,
    :message,
  ]
  class << self
    attr_reader :server_fields
  end
end
