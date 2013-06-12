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
          @service = ""
          @pages = ""
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
              @pages = @service.execute
              
              say "Folgende Eintraege stehen zur Verfuegung"
              showPagesWithContentAndID(@pages)
          elsif @eintraege_count == 0
              say "Keine Einträge vorhanden"
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
              showPagesWithContentAndID(@kopf_eintraege)
          
          elsif @kopf_count == 0
              say "Keine Kopfeintraege vorhanden"
          end
           
          request_completed
      end
      
      listen_for /Alle Inhalte/i do   
          start_connection
           
          @service.Pages.filter("Parent eq '0'")
          @kopf_eintraege = @service.execute
          
          say "Folgende Kopfeintraege stehen zur Verfuegung"  
          showPagesWithContentAndID(@kopf_eintraege)
          
          response_id = ask "Zu welcher ID möchten Sie mehr Informationen?"        
          start_all_entries(response_id)
           
          request_completed    
      end
           
      def start_connection
          @service = OData::Service.new "http://bfessfd.intern.itelligence.de:8000/sap/opu/odata/sap/ZLIST_SRV", { :username => "MAR", :password=> "Bachelor4711." }
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
          
          remove_zeros(eintraege)
          eintraege.each do |c|
              if c.Entryid == eintrag_id
                  hasContent = c.HasContent
              end
          end
          
          return hasContent
      end
        
      def getSubPages(eintrag_id)
          @service.Pages("'#{eintrag_id}'").expand('GetDetails').expand('GetDetails/GetSubpages')       
          subPages = @service.execute.first
          
          subPages.GetDetails.each do |c|
            laenge = 0
            loop do
                if c.GetDetails.Entryid[laenge] == "0"
                   laenge = laenge + 1
                else
                   c.GetDetails.Entryid = c.Entryid[laenge..8]
                   break
                end
             end
          end
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
       
      def start_all_entries(eintrag_id)
          hasContent = checkIfContent(eintrag_id)
          hasSubPages = checkIfSubPages(eintrag_id)
                  
          if hasContent == "true" && hasSubPages == "true"
              response = ask "Es gibt einen Content und Unterkapitel. Was hätten Sie gerne?"  
     
              if (response =~ /Content/i) 
                  showContent(eintrag_id)
              elsif (response =~ /Unterkapitel/i)
                  @pages = getSubPages(eintrag_id)
                  @pages.each do |c|
                      say "#{c.Name} mit der ID : #{c.Entryid}"
                  end
       
                  response = ask "Welchen?"  
                      return start_all_entries(response)
             else 
                  say "Ich konnte Sie nicht verstehen, bitte wiederholen Sie!"
                  return start_all_entries(eintrag_id)
              end
     
             elsif hasContent == "false" && hasSubPages == "true"
         
              @pages = getSubPages(eintrag_id)
              @pages.each do |c|
                 say "#{c.Name} mit der ID : #{c.Entryid}"
              end
        
              response = ask "Welchen?"  
              return start_all_entries(response)
                 
         elsif hasContent == "true" && hasSubPages == "false"
              showContent(eintrag_id)
         else   
              say "Es liegen weder Inhalt noch Unterkapitel vor"
         end
                        
    end

    def showContent(_id) 
        content = getContent(_id)
        say content
    end
       
    def showPagesWithContentAndID(page)
        remove_zeros(page)
        page.each do |c|
             say "#{c.Name} mit der ID : #{c.Entryid}"
        end
    end
       


 end
