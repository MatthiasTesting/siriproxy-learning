# -*- encoding: utf-8 -*-

require 'cora'
require 'siri_objects'
require 'pp'
require 'ruby_odata'

class SiriProxy::Plugin::Learning < SiriProxy::Plugin
  def initialize(config)
    @kopf_eintraege = ""
    @head_count = 0
    @eintraege_count = 0
    @service = OData::Service.new "http://bfessfd.intern.itelligence.de:8000/sap/opu/odata/sap/ZLIST_SRV", { :username => "MAR", :password=> "Bachelor4711." }
    @pages = ""
  end

  listen_for /SAP alle.*einträge/i do
    say "Es werden alle Einträge gesucht"

    @service.Pages.count
    @eintraege_count = @service.execute

    if @eintraege_count > 0
      @service.Pages
      @pages = @service.execute

      say "Folgende Einträge stehen zur Verfuegung"
      showPagesWithContentAndID(@pages)
    elsif @eintraege_count == 0
      say "Keine Einträge vorhanden"
    end

    request_completed

  end

  listen_for /SAP Eintrag ([0-9]*[0-9])(?: abspielen)?/i do |number|

    has_Content = "false"

    has_Content = checkIfContent(number)

    if has_Content == "true"
      showContent(number)
    else
      say "Der Eintrag hat keinen Inhalt"
    end

    request_completed
  end

  listen_for /SAP Suche.*Einträge zu ([a-z,]*[A-Z])/i do |keyword|

    keyword.upcase!

    @service.Pages.filter("Tags eq '#{keyword}'").count
    @eintraege_count = @service.execute

    if @eintraege_count > 0
      @service.Pages.filter("Tags eq '#{keyword}'")
      @pages = @service.execute
      showPagesWithContentAndID(@pages)

      response_id = ask "Welchen Eintrag möchten Sie abspielen lassen?"

      has_Content = checkIfContent(response_id)

      if has_Content == "true"
        showContent(response_id)
      elsif has_Content == "false"
        say "Das Eintrag hat keinen Inhalt"
      end
    elsif @eintraege_count == 0
      say "Keine Einträge gefunden"
    end
    request_completed
  end

  listen_for /SAP Alle (kopfeinträge|kopfdaten) suchen/i do
    Thread.new {
      
      @service.Pages.filter("Parent eq '0'").count
      @head_count = @service.execute
      say "Es werden alle Kopfeinträge gesucht"

      if @head_count > 0
        @service.Pages.filter("Parent eq '0'")
        @kopf_eintraege = @service.execute

        say "Folgende Kopfeinträge stehen zur Verfuegung"
        showPagesWithContentAndID(@kopf_eintraege)

      elsif @head_count == 0
        say "Keine Kopfeinträge vorhanden"
      end

      request_completed
    }
  end

  listen_for /SAP inhaltsverzeichnis/i do

    @service.Pages.filter("Parent eq '0'")
    @kopf_eintraege = @service.execute

    say "Folgende Kopfeinträge stehen zur Verfügung"
    showPagesWithContentAndID(@kopf_eintraege)

    response_id = ask "Zu welcher Nummer möchten Sie mehr Informationen?"

    start_all_entries(response_id)

    request_completed

  end

  def remove_zeros(_entries)
    _entries.each do |entry|
      unless entry.Entryid.nil?

        length = 0
        loop do
          if entry.Entryid[length] == "0"
          length = length + 1
          else
          entry.Entryid = entry.Entryid[length..8]
          break
          end
        end
      end
    end

  end

  def checkIfSubPages(_entryId)
    rHasSubPages = "false"
    @service.Pages("'#{_entryId}'").expand('GetDetails')

    page = @service.execute.first

    page.GetDetails.each do |p|
      rHasSubPages = p.Has_Subpages
    end

    return rHasSubPages
  end

  def checkIfContent(_entryId)
    rHasContent = "false"

    @service.Pages
    entries = @service.execute

    remove_zeros(entries)
    entries.each do |entry|
      if entry.Entryid == _entryId
      rHasContent = entry.HasContent
      end
    end

    return rHasContent
  end

  def getSubPages(_entryId)
    @service.Pages("'#{_entryId}'").expand('GetDetails').expand('GetDetails/GetSubpages')

    rSubPages = @service.execute.first

    return rSubPages.GetDetails
  end

  def getContent(_entryId)
    rContent = ""

    @service.Pages("'#{_entryId}'").expand('GetDetails')
    content = @service.execute.first

    content.GetDetails.each do |content|
      rContent = content.Content
    end

    return rContent
  end

  def start_all_entries(_entryId)
    hasContent = checkIfContent(_entryId)
    hasSubPages = checkIfSubPages(_entryId)

    if hasContent == "true" && hasSubPages == "true"
      response = ask "Es gibt einen Inhalt und dazugehörige Unterkapitel. Was würden Sie gerne angezeigt bekommen?"

      if (response =~ /Inhalt/i)
        showContent(_entryId)
      elsif (response =~ /Unterkapitel/i)
        @pages = getSubPages(_entryId)
        showPagesWithContentAndID(_entryId)

        response = ask "Welche Eintragnummer soll angezeigt werden?"

        return start_all_entries(response)
      else
        say "Ich konnte Sie nicht verstehen, bitte wiederholen Sie!"
        return start_all_entries(_entryId)
      end

    elsif hasContent == "false" && hasSubPages == "true"

      @pages = getSubPages(_entryId)
      showPagesWithContentAndID(@pages)
      response = ask "Welche Eintragnummer soll angezeigt werden?"
      return start_all_entries(response)

    elsif hasContent == "true" && hasSubPages == "false"
      showContent(_entryId)
    else
      say "Es liegen weder Inhalt noch Unterkapitel vor"
    end

  end

  def showContent(_entryId)
    content = getContent(_entryId)
    say content
  end

  def showPagesWithContentAndID(_page)
    remove_zeros(_page)
    _page.each_with_index do |page, index|
      unless index == 0 && page.Entryid.nil?
        say "#{page.Name} mit der Nummer : #{page.Entryid}"
      end
    end
  end

end
