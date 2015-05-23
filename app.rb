require './spider'

spider = Spider.new

get '/' do
  spider.start
  if spider.done?
    return {status: 'done'}.to_json
  else
    return {status: spider.progress}.to_json
  end
end
