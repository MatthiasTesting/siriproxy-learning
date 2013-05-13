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
    say "Joadsfrasada"
    svc = OData::Service.new "http://bfessfd.intern.itelligence.de:8000/sap/opu/odata/sap/ZLIST_SRV", 
    { :username => "mar", :password=> "Bachelor4711" }
      
    svc.Pages
    @kopf_eintraege = svc.execute
    @kopf_eintraege.each do |c|
        say "#{c.Entryid}"
    end
    
    request_completed
  end




end