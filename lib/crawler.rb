module Crawler
  module ASPEssential
    attr_reader :current_url

    def initialize opts = {}
    end

    def visit url
      handle_response RestClient.get url
      @current_url = url
    end

    def submit submit_name=nil, form_data={}
      submit_selector = "input[type=\"submit\"][value=\"#{submit_name}\"]"

      if submit_name.nil?
        post_hash = get_view_state.merge(form_data)
      else
        post_hash = Hash[@doc.css(submit_selector).map{|node| [node[:name], node[:value]]}].merge(get_view_state).merge(form_data)
      end

      post_path = @doc.css(submit_selector).xpath('ancestor::form[1]//@action')[0].value

      uri = URI.parse(@current_url)
      if post_path[0] == '/'
        post_path = "#{uri.scheme}://#{uri.host}/"
      else
        post_path = URI.join("#{File.dirname(uri.to_s)}/", post_path).to_s
      end

      post post_path, post_hash
    end

    def post url, opt = {}
      handle_response RestClient.post url, opt.merge({cookies: @cookies})
      @current_url = url
    end

    def get_view_state
      Hash[@doc.css('input[type="hidden"]').map {|d| [d[:name], d[:value]]}]
    end

    private
      def handle_response response
        @doc = Nokogiri::HTML response.force_encoding('utf-8')
        @cookies ||= response.cookies
      end
  end
end
