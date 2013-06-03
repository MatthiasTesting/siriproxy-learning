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

  def start_query
  
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
  
  listen_for /Nummer ([0-9,]*[0-9])/i do |page_id|
       say "Detailinformationen zu " + page_id + " werden ermittelt!"
       start_connection
      
       response = ask "Sicher " + page_id + "?"	
		     
	
	
	if (response =~ /Ja/i)
		Thread.new {
			@service.Pages("'#{page_id}'").expand('GetDetails')
	
			#@service.Pages("2").expand('GetDetails')       
			detaile = @service.execute.first
	
			detaile.GetDetails.each do |a|
				say "#{a.Content}"
			end
			request_completed
		}
       end
  end
  
	
	listen_for /Alle Inhalte/i do
		
		start_connection
		@service.Pages.filter("Parent eq '0'")
		@kopf_eintraege = @service.execute
		
		say "Folgende Kopfeintraege stehen zur Verfuegung"
		
		@kopf_eintraege.each do |c|
			say "#{c.Name} mit der ID : #{c.Entryid}"
		end
		
		response_id = ask "Welche ID anzeigen?"	
		
		@kopf_eintraege.each do |c|
			say "#{response_id} und #{c.Entryid}"
			#if response_id == c.Entryid 
			   
			#	response = ask "Content abspielen oder Unterkapitel anzeigen?"
			#	if (response =~ /Content/i) & c.HasContent == true
			#		# GetDetails 
				#	say "GetDetails"
				#	@service.Pages("'#{response_id}'").expand('GetDetails')
		
					#@service.Pages("2").expand('GetDetails')       
				#	detaile = @service.execute.first
			
				#	detaile.GetDetails.each do |a|
				#		say "#{a.Content}"
				#	end
			      #  elsif (response =~ /Unterkapitel/i)
			      #  	@service.Pages("'#{response_id}'").expand('GetDetails').expand('GetDetails/GetSubpages')
              		#		detail = @service.execute

			      #  end
		#	end	
		end
		
		   
		#@service.Pages("'#{page_id}'")
	
		#@service.Pages("2").expand('GetDetails')       
		#detaile = @service.execute.first

		#detaile.GetDetails.each do |a|
	#		say "#{a.Content}"
	#	end
		
		
		
		request_completed
	end


         #if "#{c.Has_Subpages}" == true
            #  c.Content == "" &&das
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

 

end
