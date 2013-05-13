require 'cora'
require 'siri_objects'
require 'pp'
require 'ruby_odata'

class SiriProxy::Plugin::Learning < SiriProxy::Plugin
  def initialize(config)
    @kopf_eintraege = ""
    @kopf_count = 0
    @eintraege_count = 0
    @service = OData::Service.new "http://bfessfd.intern.itelligence.de:8000/sap/opu/odata/sap/ZLIST_SRV", { :username => "mar", :password=> "Bachelor4711" }

  end

  def start_query
  
  end

  def test_connection 
    
  end
  
  listen_for /Alle Eintraege suchen/i do
    say "Es werden alle Eintraege gesucht"

          svc.Pages.count
          @eintraege_count = svc.execute
          
          say "#{@kopf_count}"
          if @eintraege_count > 0
              svc.Pages
              @eintraege = svc.execute

              say "Folgende Eintraege stehen zur Verfuegung"

              @eintraege.each do |c|
                  say "#{c.Name} mit der ID : +{c.Entryid}"
              end
          elsif @eintraege_count == 0
              say "Keine Eintraege vorhanden"
          end
         
          request_completed
  end


  listen_for /Alle Kopfeintraege suchen/i do
    say "Es werden alle Kopfeintraege gesucht"

          svc.Pages.count
          @kopf_count = svc.execute
          
          say "#{@kopf_count}"
          if @kopf_count > 0
              svc.Pages.filter("Parent eq '0'")
              @kopf_eintraege = svc.execute

              say "Folgende Kopfeintraege stehen zur Verfuegung"

              @kopf_eintraege.each do |c|
                  say "#{c.Name} mit der ID : +{c.Entryid}"
              end
          elsif @kopf_count == 0
              say "Keine Kopfeintraege vorhanden"
          end
         
          request_completed
  end
  
  listen_for /Detail zu (.*)/i do | page_id |
    say "#{@kopf_count}"
    say "Detailinformationen zu " + page_id + " werden ermittelt!", spoken: "Checking"
    # wenn Parent false ist, dann abspielen
    
    # bzw. Has Content abprüfen
  end


end