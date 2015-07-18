#!/usr/bin/env ruby
require 'open-uri'
require 'net/http'


$realm_url = "https://realm.io"
$altconf_url = "https://realm.io/altconf/"

#<div class="altconf-video-info">
#<h3><a href="/news/altconf-brice-pollock-250-days-shipping-with-swift-and-viper/">250 Days Shipping With Swift and VIPER</a></h3>
#<div class="altconf-video-speaker">Brice Pollock</div>
#<div class="altconf-video-desc" data-readmore="" aria-expanded="false" id="rmjs-1" style="max-height: none; height: 108px;">Massive-View-Controller syndrome got you down? Experiencing increasing difficulty adding new features without breaking others? Learn how an architecture called VIPER will help you squash view controller bloat, decouple your app and fulfill your desires to align to the Single Responsibility Principal. At Coursera, we’ve been evolving a version of VIPER to ship features with small, contained, testable classes which have distinct responsibilities. Meanwhile we’ve found Swift to be a welcome companion to VIPER, allowing us to further abstract behavior into enumerations, promote immutability and write safer code. What patterns have we developed? Have we found new functional paradigms useful? Find out!</div><a style="color: rgb(153, 153, 153)" href="#" data-readmore-toggle="" aria-controls="rmjs-1">Read More</a>
#</div>

def download(video_named, at_url)
  altconf_video_url = "#{$realm_url}#{at_url}"
  puts "download -> #{altconf_video_url} -> #{video_named}"
  response = Net::HTTP.get_response(URI.parse(altconf_video_url)) # => #<Net::HTTPOK 200 OK readbody=true>
  
  if response.body.match /https:\/\/embed-ssl\.wistia\.com\/deliveries\/([a-z0-9]*).bin","width":(1280),"height":([0-9]*),"ext":"(mp4)","size":([0-9]*)/
    puts "id:#{$1}"
  else 
    #puts response.body
    #https://realm.io/news/altconf-brice-pollock-250-days-shipping-with-swift-and-viper/fast.wistia.net/embed/iframe/2wvesr84ty\?videoFoam=true"
    #puts "iFrame !" 
    if response.body.match /\/\/fast\.wistia\.net\/embed\/iframe\/(.*)\?videoFoam=true/
      #puts "iframe id:#{$1}"
      altconf_ifrma_url = "http://fast.wistia.net/embed/iframe/#{$1}\?videoFoam=true%22"
      response = Net::HTTP.get_response(URI.parse(altconf_ifrma_url)) # => #<Net::HTTPOK 200 OK readbody=true>
      if response.body.match /http:\/\/embed\.wistia\.com\/deliveries\/([a-z0-9]*).bin","width":(1280),"height":([0-9]*),"ext":"(mp4)","size":([0-9]*)/
        real_video_url = "http://embed.wistia.com/deliveries/#{$1}.bin"
        #puts "real video url is #{real_video_url}"
        file_name = video_named.gsub(" ","-")+".mp4"
        file_name = file_name.gsub("\/","-")
        file_name = file_name.gsub("\'","-")
      
        if !File.exist?(file_name) 
          
          begin
            #open(file_name, 'wb') do |file|
            #  file << open(real_video_url).read
            #end
            command = "curl #{real_video_url} --output #{file_name}"
            Kernel.system command 

          rescue 
            puts "FAILED ! at url #{real_video_url}"
          end
        
        end
        
      else 
        puts response.body
      end
       
    end
    
  end
  
  #all videos https:\/\/embed-ssl\.wistia\.com\/deliveries\/([a-z0-9]*).bin","width":([0-9]*),"height":([0-9]*),"ext":"(mp4)","size":([0-9]*)
  
end

#download-page 
require 'net/http'
uri = $altconf_url 
response = Net::HTTP.get_response(URI.parse(uri)) # => #<Net::HTTPOK 200 OK readbody=true>

#split "<div class="altconf-video-info">"
parts = response.body.split("<div class=\"altconf-video-info\">")
puts "#{parts.length} potential videos detected"

parts.each { |one_div|
  #split <h3><a href="/news/altconf-glen-tregoning-paul-zabelin-successful-test-driven-development-on-ios/">Successful Test-Driven Development on iOS</a></h3>
  if one_div.match /<h3><a href="(.*)">(.*)<\/a>/
    part_link = $1
    part_title = $2
    download(part_title,part_link)    
  end
}