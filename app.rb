require './config'

get '/' do
  SpiderWorker.perform_async
  if SpiderWorker.done?
    return {status: 'done'}.to_json
  else
    return {status: SpiderWorker.progress}.to_json
  end
end

get '/courses.json' do
  if SpiderWorker.done? || File.exist?(File.join('public', 'courses.json'))
    content_type :json
    File.read(File.join('public', 'courses.json'))
  else
    return {status: SpiderWorker.progress}.to_json
  end
end
