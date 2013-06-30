class Fact
  include DataMapper::Resource

  storage_names[:default] = 'v2/facts'

  property :name, Text, :key => true
  property :value, Text

  belongs_to :node, :model => 'Node', :child_key => :certname, :key => true

  @server_fields = [:name, :value, :certname]
  class << self
    attr_reader :server_fields
  end
end
