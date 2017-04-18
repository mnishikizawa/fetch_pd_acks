#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'dotenv'
require 'json'
require 'time'

Dotenv.load

url = URI('https://api.pagerduty.com/incidents?statuses[]=acknowledged')
#url = URI('https://api.pagerduty.com/incidents')
http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

req = Net::HTTP::Get.new(url)
req['Content-Type'] = 'application/json'
req['Authorization'] = "Token token=#{ENV['PD_API_KEY']}"
req['Accept'] = 'application/vnd.pagerduty+json;version=2'

res = http.request(req)

parse = JSON.parse(res.body)

acknowledgements = []
case res
when Net::HTTPSuccess
  parse = JSON.parse(res.body)['incidents']
    parse.each do |p|
      acknowledgements << {
        ack_time: Time.parse(p['acknowledgements'][0]['at']).getlocal,
        title: p['title']
      }
    end
  else
    nil
end

now = Time.now

acknowledgements.each do |ack|
  puts ack[:title]
  puts "is not resolved" + " #{(now - ack[:ack_time]).to_i/60/60} " + "時間"
end
