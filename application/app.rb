require 'rubygems'
require 'sinatra'
require 'json'
require 'openssl'
require 'base64'
require 'net/http'

post '/linebot/callback' do
  channelID = ""
  channelSecret = ""
  channelMID = ""
  File.open("../../file","r") do |f|
    channelID = f.gets
    channelSecret = f.gets
    channelMID = f.gets
  end
  http_request_body = request.body.read # Request body string
  #hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, CHANNEL_SECRET, http_request_body)
  #signature = Base64.strict_encode64(hash)
  #logger.info signature
  #logger.info request.env["HTTP_X_LINE_CHANNELSIGNATURE"]
  #logger.info http_request_body
  parsed = JSON.parse(http_request_body)
  userchannel = parsed["result"][0]["fromChannel"]
  fromuser = parsed["result"][0]["content"]["from"]
  usertext = parsed["result"][0]["content"]["text"]

  arr = ["後門", "八方雲集", "王哥肉圓", "新明羊肉羹", "火鍋", "牛排"]
    if usertext === "吃甚麼" || usertext === "吃什麼"
      usertext = arr[rand(6)]
  end

  contentpar = {'contentType' => 1,'toType' => 1,'text' => usertext}
  to = [ fromuser ]
  params = {'to' => to, 'toChannel' => 1383378250 , 'eventType' => '138311608800106203', 'content' => contentpar}
  logger.info params.to_json
  json_headers = {'Content-type' => 'application/json; charset=UTF-8','User-Agent' => 'LINE-BotSDK/0.1.3' , 'X-Line-ChannelID' => channelID,'X-Line-ChannelSecret' => channelSecret,'X-Line-Trusted-User-With-ACL' => channelMID}
  logger.info json_headers 
 
  uri = URI.parse('https://trialbot-api.line.me/v1/events')
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  logger.info uri.path
  response = http.post(uri.path, params.to_json, json_headers)
  logger.info response.body

  exec('python','sendmsg.py', parsed["result"][0]["content"]["text"] )
end


