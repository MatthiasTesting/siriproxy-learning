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

  listen_for /Alle Kopfeintraege suchen/i do
    say "Es werden alle Kopfeintraege gesucht"
  
          svc = OData::Service.new "http://bfessfd.intern.itelligence.de:8000/sap/opu/odata/sap/ZLIST_SRV", { :username => "mar", :password=> "Bachelor4711" }
      
          svc.Pages
          @kopf_eintraege = svc.execute
          
          svc.Pages.count
          count = svc.execute
          
          say "#{count}"
          # wenn Count > 0 Einträge vorhanden,
          # ansonsten Abbruch
          say "Folgende Kopfeintraege stehen zur Verfuegung"

          @kopf_eintraege.each do |c|
              say "#{c.Name}"
          end
          
          request_completed
            
    
end
  
  listen_for /Detail zu (.*)/i do | page_name |
    say "Detailinformationen zu " + page_name + " werden ermittelt!", spoken: "Checking"
    # wenn Parent false ist, dann abspielen
    
    # bzw. Has Content abprüfen
  end

end