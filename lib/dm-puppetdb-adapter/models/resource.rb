require 'dm-types'

class Resource
  include DataMapper::Resource

  storage_names[:default] = 'v2/resources'

  property :parameters, Json
  property :sourceline, Integer
  property :sourcefile, Text
  property :exported, Boolean, :required => true
  property :type, Text, :required => true, :key => true
  property :title, Text, :required => true, :key => true
  property :tags, Json, :required => true

  belongs_to :node, :child_key => :certname, :key => true
  @server_fields = [
    :tag,
    :certname,
    :parameters,
    :type,
    :title,
    :exported,
    :sourcefile,
    :sourceline,
  ]
  class << self
    attr_reader :server_fields
  end
end
