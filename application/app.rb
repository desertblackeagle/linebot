require 'rubygems'
require 'sinatra'
require 'json'
require 'openssl'
require 'base64'
require 'net/http'

get '/' do
  "Hello"
end

post '/linebot/callback' do
  channelID = ""
  channelSecret = ""
  channelMID = ""
  File.open("../../file","r") do |f|
    channelID = f.gets
    channelSecret = f.gets
    channelMID = f.gets
  end
  channelID =  channelID.sub("\n","")
  channelSecret = channelSecret.sub("\n","")
  channelMID = channelMID.sub("\n","")
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
  json_headers = {'Content-type' => 'application/json; charset=UTF-8', 'X-Line-ChannelID' => channelID,'X-Line-ChannelSecret' => channelSecret,'X-Line-Trusted-User-With-ACL' => channelMID}
 
  uri = URI.parse('https://trialbot-api.line.me/v1/events')
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  response = http.post(uri.path, params.to_json, json_headers)
  logger.info "response" + response.body

  mids = fromuser 
  uri = URI.parse("https://trialbot-api.line.me")
  https = Net::HTTP.new(uri.host, uri.port)
  if uri.scheme == "https"
    https.use_ssl = true
  end
  mids = mids.instance_of?(String) ? [mids] : mids
  endpoint_path  = "/v1/profiles?mids=#{mids.join(',')}"
  res = https.get(endpoint_path, json_headers)
  logger.info "profile : " + res.body
  parsedprofile = JSON.parse(res.body)
  userprofilename =  parsedprofile["contacts"][0]["displayName"]
  logger.info userprofilename

  exec('python','sendmsg.py', "nick name : " + userprofilename + "\ntext : " + parsed["result"][0]["content"]["text"] )
end


