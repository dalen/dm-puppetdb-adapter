class Report
  include DataMapper::Resource

  storage_names[:default] = 'experimental/reports'

  property :id, String, :length => 40, :key => true
  property :end_time, DateTime, :field => 'end-time'
  property :start_time, DateTime, :field => 'start-time'
  property :receive_time, DateTime, :field => 'receive-time'
  property :configuration_version, String, :length => 255, :field => 'configuraion-version'
  property :report_format, Integer, :field => 'report-format'
  property :puppet_version, String, :length => 255, :field => 'puppet-version'

  belongs_to :node, :child_key => :certname

  has n, :events, :child_key => [ :report ]

  @server_fields = [ :certname ]
  class << self
    attr_reader :server_fields
  end
end
