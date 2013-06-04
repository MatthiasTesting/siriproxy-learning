# -*- encoding: utf-8 -*-

require 'cora'
require 'siri_objects'
require 'pp'
require 'ruby_odata'
 
class SiriProxy::Plugin::Learning < SiriProxy::Plugin
  def initialize(config)
    @kopf_eintraege = ""
    @kopf_count = 0
    @eintraege_count = 0
  end


  def start_connection
        @service = OData::Service.new "http://bfessfd.intern.itelligence.de:8000/sap/opu/odata/sap/ZLIST_SRV", { :username => "MAR", :password=> "Bachelor4711." }
  end
  
  def check_connection
        @service = OData::Service.new "http://bfessfd.intern.itelligence.de:8000/sap/opu/odata/sap/ZLIST_SRV", { :username => "MAR", :password=> "Bachelor4711." }
   
        if @service.respond_to? :Pages == true
          say "Connection established"
        else
          say "No Connection"
        end
       
  end
  
  listen_for /Teste Verbindung/i do
        check_connection
        request_completed
  
  end
  
        
  def showPage(page_id)  
       response = ask "Sicher " + page_id + "?"
      
       if (response =~ /Ja/i)
          Thread.new {
            @service.Pages("'#{page_id}'").expand('GetDetails')
        
            detaile = @service.execute.first
        
            detaile.GetDetails.each do |a|
              say "#{a.Content}"
              end
              request_completed
            }
        end
  end 
  
  
  listen_for /Alle Eintraege suchen/i do
    say "Es werden alle Eintraege gesucht"
          start_connection
          @service.Pages.count
          @eintraege_count = @service.execute
          
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


  listen_for /Alle (kopfeinträge|kopfdaten) suchen/i do
          start_connection
          @service.Pages.filter("Parent eq '0'").count
          @kopf_count = @service.execute
          say "Es werden alle Kopfeintraege gesucht"

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
  
  listen_for /Nummer ([0-9,]*[0-9])/i do |page_id|
    
        start_connection
       
        showPage(page_id)
  end
  
  
  listen_for /Alle Inhalte/i do
    
 
        start_connection
        
        @service.Pages.filter("Parent eq '0'")
        @kopf_eintraege = @service.execute
        
        say "Folgende Kopfeintraege stehen zur Verfuegung"
        
        @kopf_eintraege.each do |c|
          laenge = 0
          loop do
              if c.Entryid[laenge] == "0"
                 laenge = laenge + 1
              else
                 c.Entryid = c.Entryid[laenge..8]
                 break
              end
           end
        end
       
        
        @kopf_eintraege.each do |c|
              say "#{c.Name} mit der ID : #{c.Entryid}"
        end
        
        response_id = ask "Zu welcher ID möchten Sie mehr Informationen?"
        
        @kopf_eintraege.each do |eintrag|
               if response_id == eintrag.Entryid
                     if eintrag.HasContent == true 
                         response = ask "Es liegt ein Content vor oder doch Unterkapitel anzeigen lassen?"  
                         if (response =~ /Content/i) 
                           
                             showPage(eintrag.Entryid)

                         elsif (response =~ /Unterkapitel/i) 
                              @service.Pages("'#{eintrag.Entryid}'").expand('GetDetails').expand('GetDetails/GetSubpages')
                         
                              unterkapitel = @service.execute.first
                              unterkapitel.GetDetails.each do |b|
                                  say "Folgende Unterkapitel liegen vor #{b.Entryid}"
                              end
                          end
                       
                     elsif eintrag.HasContent == false
                        response = ask "Es liegt kein Content, folgende Unterkapitel stehen aber zur Verfügung?"  
                          
                     end
                      
              
              end
        end
        request_completed
       
  end
  

  
  end
