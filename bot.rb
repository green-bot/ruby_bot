#!/usr/bin/env ruby
#
#

require "./lib/greenbot.rb"
require "geocoder"
require "awesome_print"
require 'rest-client'
require 'json'
require 'uri-handler'

INITIAL_MSG = ENV['INITAL_MSG'] || "I need a lawyer to get me out of the pokie"
LOCATION_PROMPT = ENV['LOCATION_PROMPT'] || "Where are you?"
SIGNATURE = ENV['SIGNATURE'] || "Here's a link to your results: "
GOOGLE_LOCATION_KEY = ENV['GOOGLE_LOCATION_KEY']
CLASSIFIER_ID = ENV['CLASSIFIER_ID'] || "2fbbc6x326-nlc-1764"
CLASSIFIER_USERNAME = ENV['CLASSIFIER_USERNAME'] || "bae2977a-0f8c-461c-b994-658b1dbc68b2"
CLASSIFIER_PASSWORD = ENV['CLASSIFIER_PASSWORD'] || "rwcJpfpetkJ7"

# curl -G --user "bae2977a-0f8c-461c-b994-658b1dbc68b2":"rwcJpfpetkJ7" "https://gateway.watsonplatform.net/natural-language-classifier/api/v1/classifiers/2fbbc6x326-nlc-1764/classify" --data-urlencode "text=I want to move homes"
Geocoder.configure(
  :timeout => 10,
  :google => {
    :api_key => GOOGLE_LOCATION_KEY,
    :timeout => 10
  }
)

begin
  data = INITIAL_MSG.to_uri
  url = "https://gateway.watsonplatform.net/natural-language-classifier/api/v1/classifiers/#{CLASSIFIER_ID}/classify?text=#{data}"
  response = RestClient::Request.execute method: :get, url: url, user: CLASSIFIER_USERNAME, password: CLASSIFIER_PASSWORD
  category_response = JSON.parse(response.body)
  puts "{{whisper: category: #{category_response['top_class']}. confidence: #{category_response['classes'][0]['confidence']}}}"
  category_response.remember("category_info")
  reported_location = ask(LOCATION_PROMPT)
  calculated_location = Geocoder.search(reported_location)
  reported_location.remember("reported_location")
  calculated_location.first.data.remember("calculated_location")

  state = calculated_location.first.data['address_components'][2]['short_name']
  city =  calculated_location.first.data['address_components'][0]['short_name']
  category = category_response['top_class'].to_uri

  url = "https://businesslisting.thevaba.com/api/businesslistings?state=#{state}&city=#{city}&category=#{category}"
  tell SIGNATURE + url

end

