# -*- encoding: utf-8 -*-

require 'cora'
require 'siri_objects'
require 'pp'
require 'ruby_odata'
 
class SiriProxy::Plugin::Learning < SiriProxy::Plugin
  def initialize(config)
    @kopf_eintraege = ""
    @kopf_count = 0
    @pages = ""
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
  
  def remove_zeros(eintraege)
      eintraege.each do |c|
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
      
      removed_nulls = eintraege
      return removed_nulls
  end

  
  def checkIfSubPages(eintrag_id)
    
        hasSubPages = "false"
        @service.Pages("'#{eintrag_id}'").expand('GetDetails')
    
        page = @service.execute.first
    
        page.GetDetails.each do |a|
             hasSubPages = a.Has_Subpages
        end
        
        return hasSubPages
                
  end

  
  def checkIfContent(eintrag_id)
        hasContent = "false"
        @service.Pages
        eintraege = @service.execute
        eintraege_temp = remove_zeros(eintraege)
        eintraege_temp.each do |c|
            if c.Entryid == eintrag_id
                hasContent = c.HasContent
            end
        end
        return hasContent
  end
  
     
  def getSubPages(eintrag_id)
      @service.Pages("'#{eintrag_id}'").expand('GetDetails').expand('GetDetails/GetSubpages')
      
      subPages = @service.execute.first
      
      return subPages.GetDetails
  end 
  
  def getContent(eintrag_id)        
        
        rContent = ""
        
        @service.Pages("'#{eintrag_id}'").expand('GetDetails')
        
        content = @service.execute.first
    
        content.GetDetails.each do |a|
           rContent = a.Content
          end
        
        return rContent
    
  end 
  
 
  listen_for /Nummer ([0-9,]*[0-9])/i do |page_id|

  end

def start_all_entries(eintrag_id)


     hasContent = checkIfContent(eintrag_id)
     hasSubPages = checkIfSubPages(eintrag_id)
     
     say "Content  " + hasContent  + " Subpages :  " + hasSubPages
     
     if hasContent == "true" && hasSubPages == "true"
         response = ask "Es gibt einen Content und Unterkapitel. Was hätten Sie gerne?"  
     
         if (response =~ /Content/i) 
             content = getContent(eintrag_id)
             say content
           
         elsif (response =~ /Unterkapitel/i)
             @pages = getSubPages(eintrag_id)
               
             @pages.each do |c|
                say "#{c.Name} mit der ID : #{c.Entryid}"
             end
             
             response = ask "Welchen?"  
             return start_all_entries(response)
         end
           
     elsif hasContent == "false" && hasSubPages == "true"
     
         @pages = getSubPages(eintrag_id)
        
         @pages.each do |c|
            say "#{c.Name} mit der ID : #{c.Entryid}"
                           end
         
         response = ask "Welchen?"  
         return start_all_entries(response)
             
     elsif hasContent == "true" && hasSubPages == "false"
          content = getContent(eintrag_id)
          say content
     else   
        say "Es liegen"
     end
              
   
   
 end

  listen_for /Alle Inhalte/i do

        start_connection
        
        @service.Pages.filter("Parent eq '0'")
        @kopf_eintraege = @service.execute
        
        say "Folgende Kopfeintraege stehen zur Verfuegung"
        kopfeintraege = remove_zeros(@kopf_eintraege)
          
        kopfeintraege.each do |c|
              say "#{c.Name} mit der ID : #{c.Entryid}"
        end
        
        response_id = ask "Zu welcher ID möchten Sie mehr Informationen?"
        
        start_all_entries(response_id)
   
        request_completed
       
  end
  
  end
