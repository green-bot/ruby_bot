#!/usr/bin/env ruby
#
#
PROMPT_1 = ENV['PROMPT_1'] || 'Thank you for texting us. We love our vetrans'
PROMPT_2 = ENV['PROMPT_2'] || 'What service are you looking for?'
PROMPT_3 = ENV['PROMPT_3'] || 'Where are you?'
SIGNATURE = ENV['SIGNATURE'] || 'Default signature prompt'
GOOGLE_LOCATION_KEY = ENV['GOOGLE_LOCATION_KEY']

require "./lib/greenbot.rb"
require "geocoder"
require "awesome_print"

Geocoder.configure(
  :timeout => 10,
  :google => {
    :api_key => GOOGLE_LOCATION_KEY,
    :timeout => 10
  }
)

types = %w(mortgage realestate bankruptcy criminal wills divorce injury retirement insurance litigation moving )

tell PROMPT_1
choice = select(PROMPT_2, types)
choice.remember("choice")

reported_location = ask(PROMPT_3)
calculated_location = Geocoder.search(reported_location)
reported_location.remember("reported_location")
calculated_location.first.data.remember("calculated_location")

if confirm("Would you like someone to contact you?")
  contact_me = true
  contact_me.remember("contact_me")
  name = ask("When we call, who should we ask for?")
  name.remember("who_to_ask_for")
  if confirm("Is there another number we should try?")
    better_number = ask("Please enter that number with an area code")
    better_number.remember("better_number")
  end
else
  tell("No problem at all.")
end
tell SIGNATURE

