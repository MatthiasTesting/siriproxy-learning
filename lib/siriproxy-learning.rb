require 'cora'
require 'siri_objects'
require 'pp'
require 'ruby_odata'

class SiriProxy::Plugin::Learning < SiriProxy::Plugin
  def initialize(config)
    @kopf_eintraege = ""
    @kopf_count = 0
    @eintraege_count = 0
    @detail = ""
  end

  def start_query
  
  end

  def start_connection 
        @service = OData::Service.new "http://bfessfd.intern.itelligence.de:8000/sap/opu/odata/sap/ZLIST_SRV", { :username => "mar", :password=> "Bachelor4711" }
  end
  
  listen_for /Alle Eintraege suchen/i do
    say "Es werden alle Eintraege gesucht"
          start_connection
          @service.Pages.count
          @eintraege_count = @service.execute
          
          say "#{@eintraege_count}"
          if @eintraege_count > 0
              @service.Pages
              @eintraege = @service.execute

              say "Folgende Eintraege stehen zur Verfuegung"

              @eintraege.each do |c|
                  say "#{c.Name} mit der ID : #{c.Entryid}"
              end
          elsif @eintraege_count == 0
              say "Keine Eintraege vorhanden"
          end
         
          request_completed
  end


  listen_for /Alle Kopfeintraege suchen/i do
    say "Es werden alle Kopfeintraege gesucht"
          start_connection
          @service.Pages.filter("Parent eq '0'").count
          @kopf_count = @service.execute
          
          say "#{@kopf_count}"
          if @kopf_count > 0
              @service.Pages.filter("Parent eq '0'")
              @kopf_eintraege = @service.execute

              say "Folgende Kopfeintraege stehen zur Verfuegung"

              @kopf_eintraege.each do |c|
                  say "#{c.Name} mit der ID : #{c.Entryid}"
              end
          elsif @kopf_count == 0
              say "Keine Kopfeintraege vorhanden"
          end
         
          request_completed
  end
  
  listen_for /Detail zu (.*)/i do |page_id|

       say "Detailinformationen zu " + page_id + " werden ermittelt!"
       say "Du Spinner"
       say "Die viastore systems GmbH (früher Haushahn, dann Haushahn Automationssysteme) ist ein internationaler Hersteller von schlüsselfertigen Intralogistik-Anlagen für Industrie und Handel. Dazu gehören Hochregallager, automatische Kleinteilelager, Systeme zur effizienten Kommissionierung, Materialflusssystem, Shuttle-Systeme sowie Distributions- und Logistikzentren.

Das von viastore systems entwickelte Lagerverwaltungssystem viad@t schafft im Lager eine durchgängige Software-Architektur vom Lagermanagement, der Steuerung von Kommissionier-, Verpackungs- und Versandprozessen bis zum Materialflusssystem und zur Prozesssteuerung. Darüber hinaus ist viastore systems SAP Partner im Bereich Supply Chain Execution (LES/TRM und EWM). Dieser Bereich operiert unter der Bezeichnung viastore SAP Logistics Solutions eigenständig innerhalb der Gruppe und bietet Beratungs- und Softwareleistungen im SAP-Umfeld an."

      # start_connection
       
      #@service.Pages("'#{page_id}'").expand('GetDetails')
             
      #@detail = @service.execute
      
      #@detail.each do |a|
       #           say "#{a.Name} mit der ID : #{a.Entryid} und #{a.Has_Subpages}  "
        #end
         #if "#{c.Has_Subpages}" == true
            #  c.Content == "" &&
              # say "Erste Bedinggun"
               # Ask if subpages should be shown 
               #@service.Pages("'#{page_id}'").expand('GetDetails').expand('GetDetails/GetSubpages')
              # detail = @service.execute

               #detail.each do |b|
               #   say "#{b.Entryid}"
              # end 
           # else
            #   say "Content wird vorgelesen"
           #   # say "#{c.Content}"
          #  endh
       request_completed
  end


end
