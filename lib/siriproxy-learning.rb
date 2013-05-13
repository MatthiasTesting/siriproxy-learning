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

  listen_for /Alle Kopfeintraege suchenn/i do
    say "Es werden alle Kopfeintraege gesucht"
    Thread.new {
          svc = OData::Service.new "http://bfessfd.intern.itelligence.de:8000/sap/opu/odata/sap/ZLIST_SRV", { :username => "mar", :password=> "Bachelor4711" }
      
          svc.Pages
          @kopf_eintraege = svc.execute
          @kopf_eintraege.each do |c|
              say "#{c.Name}"
          end
          
          request_completed
            
    }
  end
  
  #listen_for /Detail zu (.*)/i do | page_name |
  #  say "Detailinformationen zu " + page_name + "werden ermittelt!", spoken: "Checking"
  #end

end