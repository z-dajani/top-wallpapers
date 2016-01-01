%w(net/https pry json).each { |f| require f }

module WallpaperDownloader
  def self.subreddit_top_daily_posts(subreddit_name, attempt_amount)
    if attempt_amount.between?(1, 25)
      url = "https://www.reddit.com/r/#{subreddit_name}/top/.json"
      response = get_json_response(url)
      posts = response['data']['children'].first(attempt_amount)
      extract_post_info(posts)
    else
      raise ArgumentError.new('Invalid attempt amount: not in range 1-25')
    end
  end

  ####private class methods####

  def self.get_json_response(_url)
    url = URI.parse(_url)
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port, use_ssl: true) do 
      |http| http.request(req)
    end
    raise "non-200 response: #{res.code}" unless res.code[0] == '2'
    JSON.parse(res.body)
  end

  def self.extract_post_info(posts)
    keys = ['url', 'score', 'title', 'thumbnail', 'permalink']
    posts.map do |p|
      h = {}
      keys.each { |k| h.merge!(k.to_sym => p['data'][k]) if p['data'][k] }
      h
    end
  end
  
  private_class_method :get_json_response, :extract_post_info
end
