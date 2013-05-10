require 'cora'
require 'siri_objects'
require 'pp'
require 'ruby_odata'

class SiriProxy::Plugin::Learning < SiriProxy::Plugin
  def initialize(config)
  @value = ""

    #if you have custom configuration options, process them here!
  end

  def start_query
  
  end

  listen_for /test it/i do
      say "Joadsada"
      svc = OData::Service.new "http://bfessfd.intern.itelligence.de:8000/sap/opu/odata/sap/ZLIST_SRV", 
      { :username => "mar", :password=> "Bachelor4711" }
    
    
    svc.Pages.filter("Parent eq '0'")
    prod = svc.execute
    say "#{prod.to_json}"
   request_completed
  end

end