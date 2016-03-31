%w(net/https open-uri uri json).each { |f| require f }

class ImagePost < ActiveRecord::Base
  validates :title, presence: true
  validates :url, presence: true, uniqueness: true
  validates :permalink, presence: true, uniqueness: true
  validates :thumbnail, presence: true, uniqueness: true
  validates :subreddit, presence: true
  validates :score, presence: true, numericality: { greater_than: -1 }
  validates :width, inclusion: 100..10000, allow_nil: true
  validates :height, inclusion: 100..10000, allow_nil: true
  validates_with ImagePostValidator

  SUBREDDIT_LIST = %w(wallpaper wallpapers earthporn carporn skyporn
  foodporn abandonedporn mapporn spaceporn cityporn)


  def fill_dimensions_from_title
    result = (/[0-9]{3,4}[ ]?(x|×)[ ]?[0-9]{3,4}/i).match(title)  
    return false if result.nil?
    str = result.to_s.gsub(' ', '').downcase
    x_ind = (str =~ /(×|x)/i)

    self.width = str[0...x_ind].to_i
    self.height = str[x_ind+1..str.length].to_i
    true
  end

  ####class methods

  def self.refresh_posts(subreddit_count: 11)
    return if refresh_status == :not_ready 

    SUBREDDIT_LIST.first(subreddit_count).each do |sub|
      old_posts = ImagePost.all.select{ |p| p.subreddit =~ /#{sub}/i }
      old_posts.each { |p| p.destroy }
      subreddit_top_daily_posts(sub, 10)
    end
    RefreshInstance.create
    RefreshBlock.destroy_all
  end

  def self.hr_since_last_refresh
    if (latest_refresh = RefreshInstance.last)
      latest_refresh_time = latest_refresh.created_at.to_i
      (Time.now.to_i - latest_refresh_time) / 3600
    else
      -1
    end
  end

  def self.refresh_status
    return :blocked if RefreshBlock.any?
    return :empty if ImagePost.count == 0
    hr_since_last_refresh >= 4 ? :ready : :not_ready
  end

  def self.subreddit_top_daily_posts(subreddit_name, post_attempts)
    if post_attempts.between?(1, 25)
      url = "https://www.reddit.com/r/#{subreddit_name}/top/.json"
      begin
        response = get_json_response(url)
      rescue RuntimeError => rte
      end
      posts = response['data']['children'].first(post_attempts)
      extract_post_info(posts)
    else
      raise ArgumentError.new('Invalid attempt amount: not in range 1-25')
    end
  end


  private
  

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
    post_info = posts.map do |p|
      ip = ImagePost.new(title: p['data']['title'], url: p['data']['url'],
        permalink: p['data']['permalink'], score: p['data']['score'],
        thumbnail: p['data']['thumbnail'],
        subreddit: p['data']['subreddit'])
      ip.fill_dimensions_from_title
      ip.save ? ip : nil
    end
    post_info.compact
  end

end
