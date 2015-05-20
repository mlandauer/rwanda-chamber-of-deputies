#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'date'
require 'open-uri'
require 'date'

# require 'colorize'
# require 'pry'
# require 'csv'
# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'

@BASE = 'http://www.parliament.gov.rw/'
@PAGE = @BASE + 'chamber-of-deputies/members-profile/chamber-of-deputies-members-profile/'

def noko(url)
  url.prepend @BASE unless url.start_with? 'http:'
  warn "Getting #{url}"
  Nokogiri::HTML(open(url).read) 
end

def datefrom(date)
  Date.parse(date)
end


page = noko(@PAGE)
alldata = page.css('table#memberList tr').drop(1).map do |mem|
  tds = mem.css('td')
  data = { 
    id: tds[5].css('a/@href').text[/detailId=(\d+)/, 1],
    family_name: tds[0].text.strip,
    given_name: tds[1].text.strip,
    email: tds[2].text.strip,
    party: tds[3].text.gsub(/[[:space:]]+/, ' ').gsub(/\s+\-\s+/,'-').strip,
    area: tds[4].text.strip,
    website: tds[5].css('a/@href').text,
    term: '2013',
    source: @PAGE,
  }
  data[:name] = data[:given_name] + " " + data[:family_name]
  data[:sort_name] = data[:family_name] + " " + data[:given_name]
  puts data
  data
end

ScraperWiki.save_sqlite([:id, :term], alldata)
