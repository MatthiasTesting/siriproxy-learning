require 'cora'
require 'siri_objects'
require 'pp'
require 'ruby_odata'

class SiriProxy::Plugin::Learning < SiriProxy::Plugin
  def initialize(config)
    @kopf_eintraege = ""
  end

  def start_query
  
  end

  listen_for /Alle Kopfeinträge/i do
    
    
    request_completed
  end

end